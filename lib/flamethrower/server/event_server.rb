module Flamethrower
  class EventConnection < EventMachine::Connection
    include Flamethrower::Server

    attr_accessor :server
  end

  class EventServer
    attr_reader :host, :port, :campfire_connection

    def initialize(host, port, domain, token)
      @host = host || "0.0.0.0"
      @port = port || 6667
      @domain = domain
      @token = token
    end

    def start
      EventMachine::run do
        EventMachine::start_server(@host, @port, EventConnection) do |connection|
          connection.server = self
          connection.campfire_connection = Flamethrower::Campfire::Connection.new(@domain, @token)
        end
      end
    end
  end
end
