module Flamethrower
  module Server
    include Flamethrower::IRCcommands
    include Flamethrower::Tindercommands

    attr_accessor :campfire_users, :current_user, :dispatcher

    def initialize
      @campfire_users ||= []
      @current_user ||= Flamethrower::IrcUser.new
      @dispatcher ||= Flamethrower::Dispatcher.new(self)
    end

    def after_connect
      send_motd
      send_join
      send_topic
      send_userlist(@campfire_users)
    end

    def send_message(msg)
      send_data "#{msg}\r\n"
      puts msg
      msg
    end

    def receive_data(msg)
      dispatcher.handle_message(Flamethrower::Message.new(msg))
    end

    def send_messages(*messages)
      yield(messages) if block_given?
      messages.each {|msg| send_message(msg)}
    end

  end
end
