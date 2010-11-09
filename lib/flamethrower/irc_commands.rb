module Flamethrower
  module IRCcommands
    def send_motd
      send_messages do |messages|
        messages << reply(375, ":MOTD")
        messages << reply(372, ":Welcome to Flamethrower")
        messages << reply(376, ":/End of /MOTD command")
      end
    end

    def send_topic(channel)
      send_message reply(332, "#{channel.name} :#{channel.topic}")
    end

    def send_userlist(channel, users)
      send_messages do |messages|
        display_users = (["@#{@current_user.nickname}"] + users).join("\s")
        messages << reply(353, "= #{channel.name} :#{display_users}")
        messages << reply(366, "#{channel.name} :/End of /NAMES list")
      end
    end

    def send_channel_mode(channel)
      send_message reply(324, "#{channel.name} +t")
    end

    def send_user_mode
      send_message reply(221, "+i")
    end

    def reply(code, message)
      ":#{@current_user.hostname} #{code} #{@current_user.nickname} #{message}"
    end

    def error(code)
      ":#{@current_user.hostname} #{code}"
    end
  end
end
