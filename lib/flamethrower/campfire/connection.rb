module Flamethrower
  module Campfire
    class Connection
      attr_reader :token, :domain

      include Flamethrower::Campfire::RestApi

      def initialize(domain, token, connection)
        @domain = domain
        @token = token
        @connection = connection
      end

      def fetch_my_user
        http = campfire_get("/users/me.json")
        http.callback do
          case http.response_header.status
          when 200
            json = JSON.parse(http.response)
            old_user = @connection.current_user.nickname
            new_user = Flamethrower::Campfire::User.new(json['user']).to_irc
            @connection.current_user = new_user
            @connection.send_rename(old_user, new_user.nickname)
          end
        end
      end

      def fetch_rooms
        http = campfire_get("/rooms.json")
        http.callback do
          case http.response_header.status
          when 200
            rooms = Array.new
            json = JSON.parse(http.response)
            json['rooms'].each do |room|
              rooms << Room.new(@domain, @token, room).tap do |r|
                r.connection = @connection
              end
            end
            @connection.irc_channels = rooms.map(&:to_irc)
            @connection.send_channel_list
          else
            ::FLAMETHROWER_LOGGER.debug http.response
          end
        end
      end
    end
  end
end
