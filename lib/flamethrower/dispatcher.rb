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
      if server.current_user.nick_set? && server.current_user.user_set?
        server.after_connect
      end
    end

    def handle_nick(message)
      nickname = *message.parameters
      server.current_user.nickname = nickname
      if server.current_user.nick_set? && server.current_user.user_set?
        server.after_connect
      end
    end

    def handle_mode(message)
      server.send_message("MODE #{server.channel} +t") if message.parameters.first == server.channel
    end
  end
end

