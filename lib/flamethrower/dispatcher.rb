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

    private

    def find_channel(name)
      server.channels.detect {|channel| channel.name == name}
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
      if server.channels.map(&:name).include?(message.parameters.first)
        channel = find_channel(message.parameters.first)
        server.send_channel_mode(channel)
      elsif message.parameters.first == server.current_user.nickname
        server.send_user_mode
      else
        server.send_message(server.error(Flamethrower::Irc::Codes::ERR_UNKNOWNCOMMAND))
      end
    end

    def handle_join(message)
      if server.channels.map(&:name).include?(message.parameters.first)
        channel = find_channel(message.parameters.first)
        channel.users << server.current_user
        server.send_topic(channel)
        server.send_userlist(channel)
      else
        server.send_message(server.error(Flamethrower::Irc::Codes::ERR_BADCHANNELKEY))
      end
    end
  end
end

