module Flamethrower
  module IrcCommands
    include Flamethrower::IrcCodes

    def send_motd
      send_messages do |messages|
        messages << reply(RPL_MOTDSTART, ":MOTD")
        messages << reply(RPL_MOTD, ":Welcome to Flamethrower")
        messages << reply(RPL_ENDOFMOTD, ":/End of /MOTD command")
      end
    end

    def send_topic(channel)
      send_message reply(RPL_TOPIC, "#{channel.name} :#{channel.topic}")
    end

    def send_userlist(channel, users)
      send_messages do |messages|
        display_users = (["@#{@current_user.nickname}"] + users).join("\s")
        messages << reply(RPL_NAMEREPLY, "= #{channel.name} :#{display_users}")
        messages << reply(RPL_ENDOFNAMES, "#{channel.name} :/End of /NAMES list")
      end
    end

    def send_channel_mode(channel)
      send_message reply(RPL_CHANNELMODEIS, "#{channel.name} +t")
    end

    def send_user_mode
      send_message reply(RPL_UMODEIS, "+i")
    end

    def reply(code, message)
      ":#{@current_user.hostname} #{code} #{@current_user.nickname} #{message}"
    end

    def error(code)
      ":#{@current_user.hostname} #{code}"
    end
  end
end
