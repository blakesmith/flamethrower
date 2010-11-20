module Flamethrower
  class CampfireConnection
    def initialize(domain, token)
      @domain = domain
      @token = token
      @host = "#{domain}.campfirenow.com"
    end

    def rooms
      response = http.get("/rooms.json")
      Array.new.tap do |rooms|
        case response
        when Net::HTTPSuccess
          json = JSON.parse(response.body)
          json['rooms'].each do |room|
            rooms << CampfireRoom.new(@token, room)
          end
        end
      end
    end

    private
    def http
      Net::HTTP.new(@host, 443).tap do |http|
        http.use_ssl = true
      end
    end
  end
end
