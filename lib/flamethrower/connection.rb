module Flamethrower
  module Connection
    include Flamethrower::Irc::Commands

    attr_accessor :campfire_connection, :current_user, :dispatcher, :irc_channels

    def initialize(options = {})
      @irc_channels = []
      @current_user = Flamethrower::Irc::User.new
      @dispatcher = Flamethrower::Dispatcher.new(self)
    end

    def after_connect
      send_motd
      populate_irc_channels
      populate_my_user
    end

    def send_message(msg)
      send_data "#{msg}\r\n"
      ::FLAMETHROWER_LOGGER.debug ">> #{msg}"
      msg
    end

    def receive_data(msg)
      messages = msg.split("\r\n")
      messages.each do |message|
        dispatcher.handle_message(Flamethrower::Irc::Message.new(message))
        ::FLAMETHROWER_LOGGER.debug "<< #{message}"
      end
    end

    def send_messages(*messages)
      yield(messages) if block_given?
      messages.each {|msg| send_message(msg)}
    end

    def populate_irc_channels
      campfire_connection.fetch_rooms
    end

    def populate_my_user
      campfire_connection.fetch_my_user
    end

  end
end
