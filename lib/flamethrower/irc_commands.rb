module Flamethrower
  module IRCcommands
    def channel
      "&flamethrower"
    end

    def send_motd
      send_messages do |messages|
        messages << ":#{@current_user.host} 375 #{@current_user.nick} :MOTD"
        messages << ":#{@current_user.host} 372 #{@current_user.nick} :Welcome to Flamethrower"
        messages << ":#{@current_user.host} 376 #{@current_user.nick} :/End of /MOTD command"
      end
    end

    def send_join
      send_messages do |messages|
        messages << ":#{@current_user.nick}!#{@current_user.user}@#{@current_user.host} JOIN :#{channel}"
        messages << "#{@current_user.host} MODE #{channel} +t"
      end
    end

    def send_topic
      send_message ":#{@current_user.host} 332 #{@current_user.nick} #{channel} :Welcome to Flamethrower"
    end

    def send_userlist(users)
      send_messages do |messages|
        messages << ":#{@current_user.host} 353 #{@current_user.nick} = #{channel} :@#{current_user.nick} #{users.join("\s")}"
        messages << ":#{@current_user.host} 366 #{@current_user.nick} #{channel} :/End of /NAMES list"
      end
    end
  end
end
