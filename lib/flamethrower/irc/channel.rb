module Flamethrower
  module Irc
    class Channel

      attr_accessor :name, :modes, :mode
      attr_writer :topic

      def initialize(name, campfire_channel=nil)
        @users = []
        @name = name
        @modes = ["t"]
        @campfire_channel = campfire_channel
      end

      def mode
        "+#{@modes.join}"
      end

      def topic
        return "No topic" if @topic && @topic.empty?
        @topic
      end

      def to_campfire
        @campfire_channel
      end

      def users=(users)
        @users = users
      end

      def users
        @users.concat(@campfire_channel.users.map(&:to_irc))
      end

      def retrieve_irc_messages
        to_campfire.retrieve_messages.map{|message| message.to_irc}
      end

    end
  end
end
