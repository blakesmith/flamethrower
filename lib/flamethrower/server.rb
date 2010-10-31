module Flamethrower
  module Server
    include Flamethrower::IRCcommands
    include Flamethrower::Tindercommands

    attr_accessor :campfire_users, :current_user

    def initialize
      @campfire_users ||= []
      @current_user ||= Flamethrower::IrcUser.new :user => 'blake', :nick => 'blake', :host => 'localhost', :realname => 'Blake Smith'
    end

    def post_init
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

    def send_messages(*messages)
      yield(messages) if block_given?
      messages.each {|msg| send_message(msg)}
    end

  end
end
