module Flamethrower
  module Campfire
    class Room
      include Flamethrower::Campfire::RestApi

      attr_reader :stream, :token
      attr_accessor :inbound_messages, :outbound_messages, :thread_messages, :number, :name, :users, :server

      def initialize(domain, token, params = {})
        @domain = domain
        @token = token
        @inbound_messages = Queue.new
        @outbound_messages = Queue.new
        @number = params['id']
        @name = params['name']
        @topic = params['topic']
        @users = []
        @stop_thread = false
      end

      def topic=(topic)
        @topic = topic
      end

      def topic
        @topic || "No topic"
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
        Thread.new do
          connect
          until kill_thread?
            fetch_messages
            post_messages
            messages_to_send = to_irc.retrieve_irc_messages
            messages_to_send.each do |m| 
              ::FLAMETHROWER_LOGGER.debug "Sending irc message #{m.to_s}"
              @server.send_message(m.to_s)
            end
            sleep 0.5
          end
        end
      end

      def kill_thread?
        @stop_thread
      end

      def kill_thread!
        @stop_thread = true
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
          @inbound_messages << Flamethrower::Campfire::Message.new(params)
        end
      end

      def post_messages
        failed_messages = []
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
            failed_messages << message
          end
        end
        failed_messages.each {|m| @outbound_messages << m}
      end

      def retrieve_messages
        Array.new.tap do |new_array|
          until @inbound_messages.empty?
            new_array << @inbound_messages.pop
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
