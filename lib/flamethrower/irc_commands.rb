module Flamethrower
  module IRCcommands
    def channel
      "flamethrower"
    end

    def send_join
      say "JOIN ##{channel}"
    end

    def send_topic
      say "RPL_TOPIC :Welcome to Flamethrower"
    end

    def send_userlist
      users = @campfire_users.join("\s")
      say "RPL_NAMEREPLY :##{channel} @#{current_user.user} #{users}"
    end
  end
end
