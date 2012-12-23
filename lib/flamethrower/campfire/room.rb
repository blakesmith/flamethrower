module Flamethrower
  module Campfire
    class Room
      MAX_RECONNECT_TIMOUT_SECONDS = 20
      POLL_SECONDS = 0.5
      PERIODIC_UPDATE_SECONDS = 60 * 10

      include Flamethrower::Campfire::RestApi
      include Flamethrower::AsciiImager

      attr_reader :stream, :token
      attr_writer :topic
      attr_accessor :inbound_messages, :outbound_messages, :thread_messages, :number, :name, :users, :connection
      attr_accessor :failed_messages, :joined

      def initialize(domain, token, params = {})
        @domain = domain
        @token = token
        @inbound_messages = Queue.new
        @outbound_messages = Queue.new
        @users_to_fetch = Queue.new
        @images_to_fetch = Queue.new
        @uploads_to_fetch = Queue.new
        @failed_messages = []
        @number = params['id']
        @name = params['name']
        @topic = params['topic']
        @users = []
        @joined = false
        @room_info_sent = false
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
        @connection.send_topic(to_irc)
        @connection.send_userlist(to_irc)
      end

      def fetch_room_info
        http = campfire_get("/room/#{@number}.json")
        http.callback do
          case http.response_header.status
          when 200
            old_users = @users
            @users = []
            json = JSON.parse(http.response)
            json['room']['users'].each do |user|
              @users << Flamethrower::Campfire::User.new(user)
            end
            resolve_renames(old_users, @users)
            unless @room_info_sent
              send_info
              fetch_recent_messages
            end
            @room_info_sent = true
          end
        end
      end

      def fetch_recent_messages
        http = campfire_get("/room/#{@number}/recent.json", :limit => 10)
        http.callback do
          case http.response_header.status
          when 200
            json = JSON.parse(http.response)
            json['messages'].each do |json_message|
              process_inbound_json_message(json_message)
            end
          end
        end
      end

      def resolve_renames(old_users, new_users)
        old_users.each do |old_user|
          user = new_users.detect {|new_user| new_user.number == old_user.number}
          if user
            unless old_user.name == user.name
              @connection.send_rename(old_user.to_irc.nickname, user.to_irc.nickname)
            end
          end
        end
      end

      def say(body, message_type='TextMessage')
        params = {'body' => translate_nicknames(body), 'type' => message_type, 'direction' => 'outbound'}
        sort_and_dispatch_message(Flamethrower::Campfire::Message.new(params))
      end

      def start
        @room_alive = true
        fetch_room_info
        connect
        @polling_timer = EventMachine.add_periodic_timer(POLL_SECONDS) { poll }
        @periodic_timer = EventMachine.add_periodic_timer(PERIODIC_UPDATE_SECONDS) { fetch_room_info }
      end

      def stop
        @stream.stop if @stream
        EventMachine.cancel_timer(@polling_timer)
        EventMachine.cancel_timer(@periodic_timer)
        @room_alive = false
        @room_info_sent = false
      end

      def poll
        unless dead?
          requeue_failed_messages
          fetch_messages
          post_messages
          fetch_users
          fetch_images
          fetch_uploads
          messages_to_send = to_irc.retrieve_irc_messages
          messages_to_send.each do |m|
            ::FLAMETHROWER_LOGGER.debug "Sending irc message #{m.to_s}"
            @connection.send_message(m.to_s)
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
        setup_stream_callbacks
      end

      def fetch_messages
        @stream.each_item do |item| 
          ::FLAMETHROWER_LOGGER.debug "Got json message #{item.inspect}"
          process_inbound_json_message(JSON.parse(item))
        end
      end

      def fetch_images
        until @images_to_fetch.empty?
          message = @images_to_fetch.pop
          message.image_urls.each do |url|
            http = image_get(url)
            http.callback do
              case http.response_header.status
              when 200
                message.set_ascii_image(http.response)
              else
                message.mark_failed!
              end
              sort_and_dispatch_message(message)
            end
          end
        end
      end

      def fetch_uploads
        if @uploads_to_fetch.empty?
          return
        end

        http = campfire_get("/room/#{@number}/uploads.json")
        http.callback do
          case http.response_header.status
          when 200
            json = JSON.parse(http.response)
          else
            return
          end

          until @uploads_to_fetch.empty?
            message = @uploads_to_fetch.pop
            json['uploads'].each do |upload|
              if message.matching_upload(upload)
                break
              end
            end
            # We fall off the end of the loop if we didn't find a matching
            # upload. There's not much we can do, and message.to_irc
            # will complain in its generated message accordingly.
            sort_and_dispatch_message(message)
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
            else
              message.mark_failed!
            end
            sort_and_dispatch_message(message)
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
              sort_and_dispatch_message(message)
            end
          end
        end
      end

      def retrieve_messages
        Array.new.tap do |new_array|
          until @inbound_messages.empty?
            message = @inbound_messages.pop
            next unless message
            unless message.user.to_irc.nickname == @connection.current_user.nickname
              new_array << message
            end
          end
        end
      end

      def requeue_failed_messages
        @failed_messages.each do |m| 
          if m.retry_at > Time.now
            m.mark_pending!
            sort_and_dispatch_message(m)
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

      def on_reconnect
        ::FLAMETHROWER_LOGGER.debug "Reconnected to #{name} stream"
      end

      def on_error
        ::FLAMETHROWER_LOGGER.debug "There was an error connecting to #{name} stream"
      end

      def on_max_reconnects
        ::FLAMETHROWER_LOGGER.debug "Failed to reconnect to #{name}, restarting room in #{MAX_RECONNECT_TIMOUT_SECONDS} seconds"
      end

      private

      def sort_and_dispatch_message(message)
        if message.failed?
          @failed_messages << message
        elsif message.inbound?
          sort_and_dispatch_inbound_message(message)
        else
          @outbound_messages << message
        end
      end

      def sort_and_dispatch_inbound_message(message)
        if !message.user
          @users_to_fetch << message
        elsif @connection.server.ascii_conversion['enabled'] && message.needs_image_conversion?
          @images_to_fetch << message
        elsif message.needs_upload_url?
          @uploads_to_fetch << message
        else
          @inbound_messages << message
        end
      end

      def process_inbound_json_message(json_message)
        json_message['user'] = @users.find {|u| u.number == json_message['user_id'] }
        json_message['room'] = self
        json_message['direction'] = 'inbound'
        message = Flamethrower::Campfire::Message.new(json_message)
        unless message.message_type == "TimestampMessage"
          sort_and_dispatch_message(message)
        end
      end

      def translate_nicknames(message_body)
        @users.each do |user|
          if message_body.include?(user.to_irc.nickname)
            message_body.gsub!(user.to_irc.nickname, user.name)
          end
        end
        message_body
      end

      def setup_stream_callbacks
        @stream.on_reconnect { self.on_reconnect }
        @stream.on_error { self.on_error }
        @stream.on_max_reconnects { self.on_max_reconnects }
      end

    end
  end
end
