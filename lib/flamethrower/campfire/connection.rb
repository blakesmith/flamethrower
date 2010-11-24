module Flamethrower
  module Campfire
    class Connection
      attr_reader :token, :domain

      include Flamethrower::Campfire::RestApi

      def initialize(domain, token)
        @domain = domain
        @token = token
      end

      def rooms
        response = campfire_get("/rooms.json")
        Array.new.tap do |rooms|
          case response
          when Net::HTTPSuccess
            json = JSON.parse(response.body)
            json['rooms'].each do |room|
              rooms << Room.new(@domain, @token, room)
            end
          end
        end
      end

    end
  end
end
