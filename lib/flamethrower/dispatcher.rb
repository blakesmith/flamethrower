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

    def find_channel_or_error(name, error=Flamethrower::Irc::Codes::ERR_BADCHANNELKEY)
      channel = server.irc_channels.detect {|channel| channel.name == name}
      if channel && block_given?
        yield(channel)
      else
        server.send_message(server.error(error))
      end
    end

    protected

    def handle_privmsg(message)
      name, body = *message.parameters
      find_channel_or_error(name) do |channel|
        channel.to_campfire.say(body)
      end
    end

    def handle_ping(message)
      hostname = *message.parameters
      server.send_pong(hostname)
    end

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
      first_param = message.parameters.first
      error = Flamethrower::Irc::Codes::ERR_UNKNOWNCOMMAND
      if first_param == server.current_user.nickname
        server.send_user_mode
        return
      end
      find_channel_or_error(first_param, error) do |channel|
        server.send_channel_mode(channel)
      end
    end

    def handle_join(message)
      find_channel_or_error(message.parameters.first) do |channel|
        room = channel.to_campfire
        channel.users << server.current_user
        room.fetch_room_info
        room.start_thread
        server.send_topic(channel)
        server.send_userlist(channel)
      end
    end

    def handle_part(message)
      find_channel_or_error(message.parameters.first) do |channel|
        room = channel.to_campfire
        room.kill_thread!
      end
    end
  end
end

