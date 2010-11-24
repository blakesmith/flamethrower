module Flamethrower
  class EventConnection < EventMachine::Connection
    include Flamethrower::Server

    attr_accessor :server
  end

  class EventServer
    def initialize(host, port)
      @host = host || "0.0.0.0"
      @port = port || 6667
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
