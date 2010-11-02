module Flamethrower
  module IRCcommands
    def channel
      "&flamethrower"
    end

    def send_motd
      send_messages do |messages|
        messages << ":#{@current_user.hostname} 375 #{@current_user.nickname} :MOTD"
        messages << ":#{@current_user.hostname} 372 #{@current_user.nickname} :Welcome to Flamethrower"
        messages << ":#{@current_user.hostname} 376 #{@current_user.nickname} :/End of /MOTD command"
      end
    end

    def send_join
      send_messages do |messages|
        messages << ":#{@current_user.nickname}!#{@current_user.username}@#{@current_user.hostname} JOIN :#{channel}"
        messages << "#{@current_user.hostname} MODE #{channel} +t"
      end
    end

    def send_topic
      send_message ":#{@current_user.hostname} 332 #{@current_user.nickname} #{channel} :Welcome to Flamethrower"
    end

    def send_userlist(users)
      send_messages do |messages|
        messages << ":#{@current_user.hostname} 353 #{@current_user.nickname} = #{channel} :@#{current_user.nickname} #{users.join("\s")}"
        messages << ":#{@current_user.hostname} 366 #{@current_user.nickname} #{channel} :/End of /NAMES list"
      end
    end
  end
end
