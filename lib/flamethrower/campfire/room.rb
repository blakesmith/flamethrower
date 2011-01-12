module Flamethrower
  module Campfire
    class Room
      include Flamethrower::Campfire::RestApi

      attr_reader :stream, :token
      attr_writer :topic
      attr_accessor :inbound_messages, :outbound_messages, :thread_messages, :number, :name, :users, :server
      attr_accessor :failed_messages

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
        @thread_running = false
      end

      def topic
        @topic || "No topic"
      end

      def send_topic!(topic)
        response = campfire_put("/room/#{@number}.json", {:topic => topic}.to_json)
        @topic = topic if response.code == "200"
      end

      def fetch_room_info
        response = campfire_get("/room/#{@number}.json")
        json = JSON.parse(response.body)
        json['room']['users'].each do |user|
          @users << Flamethrower::Campfire::User.new(user)
        end
      end

      def say(body, message_type='TextMessage')
        params = {'body' => body, 'type' => message_type}
        @outbound_messages << Flamethrower::Campfire::Message.new(params)
      end

      def start_thread
        ::FLAMETHROWER_LOGGER.debug "Starting thread for room #{name}"
        @thread_running = true
        Thread.new do
          connect
          until dead?
            fetch_messages
            post_messages
            requeue_failed_messages
            fetch_users
            messages_to_send = to_irc.retrieve_irc_messages
            messages_to_send.each do |m| 
              ::FLAMETHROWER_LOGGER.debug "Sending irc message #{m.to_s}"
              @server.send_message(m.to_s)
            end
            sleep 0.5
          end
        end
      end

      def alive?
        @thread_running
      end

      def dead?
        !@thread_running
      end

      def kill_thread!
        @thread_running = false
      end

      def join
        campfire_post("/room/#{@number}/join.json").code == "200"
      end

      def connect
        ::FLAMETHROWER_LOGGER.debug "Connecting to #{name} stream"
        @stream = Twitter::JSONStream.connect(:path => "/room/#{@number}/live.json", 
                                    :host => "streaming.campfirenow.com", 
                                    :auth => "#{@token}:x")
      end

      def fetch_messages
        @stream.each_item do |item| 
          params = JSON.parse(item)
          ::FLAMETHROWER_LOGGER.debug "Got json message #{params.inspect}"
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
          response = campfire_get("/users/#{message.user_id}.json")
          case response
          when Net::HTTPOK
            json = JSON.parse(response.body)
            user = Flamethrower::Campfire::User.new(json['user'])
            message.user = user
            @users << user
            @inbound_messages << message
          end
        end
      end

      def post_messages
        until @outbound_messages.empty?
          message = @outbound_messages.pop
          json = {"message" => {"body" => message.body, "type" => message.message_type}}.to_json
          ::FLAMETHROWER_LOGGER.debug "Sending #{json} to campfire API"
          response = campfire_post("/room/#{@number}/speak.json", json)
          case response
          when Net::HTTPCreated
            message.mark_delivered!
          else
            ::FLAMETHROWER_LOGGER.debug "Failed to post to campfire API with code: #{response.inspect}"
            message.mark_failed!
            @failed_messages << message
          end
        end
      end

      def retrieve_messages
        Array.new.tap do |new_array|
          until @inbound_messages.empty?
            new_array << @inbound_messages.pop
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
