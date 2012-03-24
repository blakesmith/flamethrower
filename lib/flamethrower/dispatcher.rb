module Flamethrower
  class Dispatcher
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end
    
    def handle_message(message)
      method = "handle_#{message.command.downcase}"
      send(method, message) if protected_methods.map(&:to_s).include?(method)
    end

    private

    def find_channel_or_error(name, error=Flamethrower::Irc::Codes::ERR_BADCHANNELKEY)
      channel = connection.irc_channels.detect {|channel| channel.name == name}
      if channel && block_given?
        yield(channel)
      else
        connection.send_message(connection.error(error))
      end
    end

    protected

    def handle_privmsg(message)
      name, body = message.parameters
      find_channel_or_error(name) do |channel|
        channel.to_campfire.say(body)
      end
    end

    def handle_ping(message)
      hostname = message.parameters.first
      connection.send_pong(hostname)
    end

    def handle_user(message)
      username, hostname, servername, realname = message.parameters
      connection.current_user.username ||= username
      connection.current_user.hostname ||= hostname
      connection.current_user.servername ||= servername
      connection.current_user.realname ||= realname
      if connection.current_user.nick_set? && connection.current_user.user_set?
        connection.after_connect
      end
    end

    def handle_nick(message)
      nickname = message.parameters.first
      connection.current_user.nickname = nickname
      if connection.current_user.nick_set? && connection.current_user.user_set?
        connection.after_connect
      end
    end

    def handle_topic(message)
      find_channel_or_error(message.parameters.first) do |channel|
        channel.to_campfire.send_topic(message.parameters.last) if message.parameters.size > 1
        connection.send_topic(channel)
      end
    end

    def handle_mode(message)
      first_param = message.parameters.first
      error = Flamethrower::Irc::Codes::ERR_UNKNOWNCOMMAND
      if first_param == connection.current_user.nickname
        connection.send_user_mode
        return
      else
        find_channel_or_error(first_param, error) do |channel|
          connection.send_channel_mode(channel)
        end
      end
    end

    def handle_join(message)
      find_channel_or_error(message.parameters.first) do |channel|
        room = channel.to_campfire
        channel.users << connection.current_user
        room.join
        room.start
        connection.send_join(connection.current_user, channel)
      end
    end

    def handle_away(message)
      away_message = message.parameters.first
      if !away_message || away_message.empty?
        connection.current_user.away_message = nil
        connection.send_unaway
      else
        connection.current_user.away_message = away_message
        connection.send_nowaway
      end
    end

    def handle_who(message)
      find_channel_or_error(message.parameters.first) do |channel|
        connection.send_who(channel)
      end
    end

    def handle_part(message)
      find_channel_or_error(message.parameters.first) do |channel|
        room = channel.to_campfire
        room.stop
        connection.send_part(connection.current_user, channel)
      end
    end

    def handle_quit(message)
      connection.irc_channels.each {|c| c.to_campfire.stop}
    end
  end
end

