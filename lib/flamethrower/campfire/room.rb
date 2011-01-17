module Flamethrower
  module Campfire
    class Room
      POLL_SECONDS = 0.5
      PERIODIC_UPDATE_SECONDS = 60 * 5

      include Flamethrower::Campfire::RestApi

      attr_reader :stream, :token
      attr_writer :topic
      attr_accessor :inbound_messages, :outbound_messages, :thread_messages, :number, :name, :users, :server
      attr_accessor :failed_messages, :joined

      def initialize(domain, token, params = {})
        @domain = domain
        @token = token
        @inbound_messages = Queue.new
        @outbound_messages = Queue.new
        @users_to_fetch = Queue.new
        @failed_messages = []
        @number = params['id']
        @name = params['name']
        @topic = params['topic']
        @users = []
        @joined = false
        @room_alive = false
      end

      def topic
        @topic || "No topic"
      end

      def send_topic(topic)
        http = campfire_put("/room/#{@number}.json", {:topic => topic}.to_json)
        http.callback do
          @topic = topic if http.response_header.status == 200
        end
      end

      def send_info
        @server.send_topic(to_irc)
        @server.send_userlist(to_irc)
      end

      def fetch_room_info
        http = campfire_get("/room/#{@number}.json")
        http.callback do
          case http.response_header.status
          when 200
            @users = []
            json = JSON.parse(http.response)
            json['room']['users'].each do |user|
              @users << Flamethrower::Campfire::User.new(user)
            end
            send_info unless @joined
          end
        end
      end

      def say(body, message_type='TextMessage')
        params = {'body' => body, 'type' => message_type}
        @outbound_messages << Flamethrower::Campfire::Message.new(params)
      end

      def start
        @room_alive = true
        connect
        @polling_timer = EventMachine.add_periodic_timer(POLL_SECONDS) { poll }
        @periodic_timer = EventMachine.add_periodic_timer(ROOM_UPDATE_SECONDS) {fetch_room_info }
      end

      def stop
        @room_alive = false
        EventMachine.cancel_timer(@polling_timer)
        EventMachine.cancel_timer(@periodic_timer)
      end

      def poll
        unless dead?
          fetch_messages
          post_messages
          requeue_failed_messages
          fetch_users
          messages_to_send = to_irc.retrieve_irc_messages
          messages_to_send.each do |m|
            ::FLAMETHROWER_LOGGER.debug "Sending irc message #{m.to_s}"
            @server.send_message(m.to_s)
          end
        end
      end

      def alive?
        @room_alive
      end

      def dead?
        !@room_alive
      end

      def join
        http = campfire_post("/room/#{@number}/join.json")
        http.callback do
          @joined = true if http.response_header.status == 200
        end
      end

      def connect
        ::FLAMETHROWER_LOGGER.debug "Connecting to #{name} stream"
        @stream = Twitter::JSONStream.connect(:path => "/room/#{@number}/live.json", 
                                    :host => "streaming.campfirenow.com", 
                                    :auth => "#{@token}:x")
      end

      def fetch_messages
        @stream.each_item do |item| 
          ::FLAMETHROWER_LOGGER.debug "Got json message #{item.inspect}"
          params = JSON.parse(item)
          params['user'] = @users.find {|u| u.number == params['user_id'] }
          params['room'] = self
          message = Flamethrower::Campfire::Message.new(params)
          unless message.message_type == "TimestampMessage"
            unless message.user
              @users_to_fetch << message
            else
              @inbound_messages << message
            end
          end
        end
      end

      def fetch_users
        until @users_to_fetch.empty?
          message = @users_to_fetch.pop
          http = campfire_get("/users/#{message.user_id}.json")
          http.callback do
            case http.response_header.status
            when 200
              json = JSON.parse(http.response)
              user = Flamethrower::Campfire::User.new(json['user'])
              message.user = user
              @users << user
              @inbound_messages << message
            end
          end
        end
      end

      def post_messages
        until @outbound_messages.empty?
          message = @outbound_messages.pop
          json = {"message" => {"body" => message.body, "type" => message.message_type}}.to_json
          ::FLAMETHROWER_LOGGER.debug "Sending #{json} to campfire API"
          http = campfire_post("/room/#{@number}/speak.json", json)
          http.callback do
            case http.response_header.status
            when 201
              message.mark_delivered!
            else
              ::FLAMETHROWER_LOGGER.debug "Failed to post to campfire API with code: #{http.response_header.status} body: #{http.response}"
              message.mark_failed!
              @failed_messages << message
            end
          end
        end
      end

      def retrieve_messages
        Array.new.tap do |new_array|
          until @inbound_messages.empty?
            message = @inbound_messages.pop
            next unless message
            unless message.user.to_irc.nickname == @server.current_user.nickname
              new_array << message
            end
          end
        end
      end

      def requeue_failed_messages
        @failed_messages.each do |m| 
          if m.retry_at > Time.now
            @outbound_messages << m 
            @failed_messages.delete(m)
          end
        end
      end

      def to_irc
        name = "##{@name.downcase.scan(/[A-Za-z0-9]+/).join("_")}"
        @irc_channel = Flamethrower::Irc::Channel.new(name, self)
        @irc_channel.tap do |channel|
          channel.users = @users.map(&:to_irc)
          channel.topic = topic.gsub("\n", "\s")
        end
      end
    end
  end
end
