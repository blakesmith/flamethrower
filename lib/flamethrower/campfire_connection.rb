module Flamethrower
  class CampfireConnection
    include Flamethrower::Campfire::RestApi

    def initialize(domain, token)
      @domain = domain
      @token = token
    end

    def rooms
      response = http.get("/rooms.json")
      Array.new.tap do |rooms|
        case response
        when Net::HTTPSuccess
          json = JSON.parse(response.body)
          json['rooms'].each do |room|
            rooms << CampfireRoom.new(@domain, @token, room)
          end
        end
      end
    end

  end
end
