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
      send_message ":#{@current_user.hostname} 332 #{@current_user.nickname} #{channel.name} :#{channel.topic}"
    end

    def send_userlist(channel, users)
      send_messages do |messages|
        display_users = (["@#{@current_user.nickname}"] + users).join("\s")
        messages << ":#{@current_user.hostname} 353 #{@current_user.nickname} = #{channel.name} :#{display_users}"
        messages << ":#{@current_user.hostname} 366 #{@current_user.nickname} #{channel.name} :/End of /NAMES list"
      end
    end
  end
end
