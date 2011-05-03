module Flamethrower
  class MockConnection
    include Flamethrower::Connection

    def send_data(msg)
    end

    def campfire_connection
      Flamethrower::Campfire::Connection.new("mydomain", "mytoken", self)
    end

    def server
      Flamethrower::EventServer.new
    end

  end
end
