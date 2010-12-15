module Flamethrower
  module Server
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
      send_channel_list
    end

    def send_message(msg)
      send_data "#{msg}\r\n"
      ::FLAMETHROWER_LOGGER.debug ">> #{msg}"
      msg
    end

    def receive_data(msg)
      messages = msg.split("\r\n")
      messages.each do |message|
        dispatcher.handle_message(Flamethrower::Message.new(message))
        ::FLAMETHROWER_LOGGER.debug "<< #{message}"
      end
    end

    def send_messages(*messages)
      yield(messages) if block_given?
      messages.each {|msg| send_message(msg)}
    end

    def populate_irc_channels
      @irc_channels = campfire_connection.rooms.map(&:to_irc)
    end

  end
end
