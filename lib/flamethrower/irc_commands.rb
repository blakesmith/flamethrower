module Flamethrower
  module IRCcommands
    def send_motd
      send_messages do |messages|
        messages << ":#{@current_user.hostname} 375 #{@current_user.nickname} :MOTD"
        messages << ":#{@current_user.hostname} 372 #{@current_user.nickname} :Welcome to Flamethrower"
        messages << ":#{@current_user.hostname} 376 #{@current_user.nickname} :/End of /MOTD command"
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

    private

    def reply(code, message)
      ":#{@current_user.hostname} #{code} #{@current_user.nickname} #{message}"
    end
  end
end
