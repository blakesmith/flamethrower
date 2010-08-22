module Flamethrower
  module IRCcommands
    def channel
      "flamethrower"
    end

    def send_join
      send_data "JOIN ##{channel}"
    end

    def send_topic
      send_data "RPL_TOPIC :Welcome to Flamethrower"
    end

    def send_userlist
      users = @campfire_users.join("\s")
      send_data "RPL_NAMEREPLY :##{channel} @#{current_user} #{users}"
    end
  end
end
