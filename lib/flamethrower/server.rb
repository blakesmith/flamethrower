module Flamethrower
  module Server
    include Flamethrower::IRCcommands
    include Flamethrower::Tindercommands

    attr_accessor :campfire_users, :current_user

    def init
      @campfire_users ||= []
      @current_user ||= "me"
    end

    def post_init
      init
      send_join
      send_topic
      send_userlist
    end

    def say(msg)
      send_data msg
      puts msg
    end

  end
end
