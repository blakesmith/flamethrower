module Flamethrower
  class Dispatcher
    attr_reader :server

    def initialize(server)
      @server = server
    end
    
    def handle_message(message)
      method = "handle_#{message.command.downcase}"
      send(method, message) if protected_methods.include?(method)
    end

    protected


    def handle_user(message)
      username, hostname, servername, realname = *message.parameters
      server.current_user.username = username unless server.current_user.username
      server.current_user.hostname = hostname unless server.current_user.hostname
      server.current_user.servername = servername unless server.current_user.servername
      server.current_user.realname = realname unless server.current_user.realname
    end

    def handle_nick(message)
      nickname = *message.parameters
      server.current_user.nickname = nickname
    end
  end
end

