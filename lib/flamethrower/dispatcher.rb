module Flamethrower
  class Dispatcher
    attr_reader :server

    def initialize(server)
      @server = server
    end
    
    def handle_message(message)
      method = message.command.downcase
      send(method, message) if protected_methods.include?(method)
    end

    protected

    def user(message)
      username, hostname, servername, realname = *message.parameters
      server.current_user = Flamethrower::IrcUser.new(:username => username,
                                                      :hostname => hostname,
                                                      :servername => servername,
                                                      :realname => realname)
    end
  end
end

