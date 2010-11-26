module Flamethrower
  class MockServer
    include Flamethrower::Server

    def send_data(msg)
    end

    def campfire_connection
      Flamethrower::Campfire::Connection.new("mydomain", "mytoken")
    end
  end
end
