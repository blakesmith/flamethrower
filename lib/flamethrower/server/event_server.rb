module Flamethrower
  class EventConnection < EventMachine::Connection
    include Flamethrower::Server

    attr_accessor :server
  end

  class EventServer
    def initialize(host="0.0.0.0", port = 6667)
      @host = host
      @port = port
    end

    def start
      EventMachine::run do
        EventMachine::start_server(@host, @port, EventConnection) do |connection|
          connection.server = self
        end
      end
    end
  end
end
