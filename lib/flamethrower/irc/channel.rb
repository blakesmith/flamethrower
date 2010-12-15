module Flamethrower
  module Irc
    class Channel

      attr_accessor :name, :modes, :mode

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
        campfire_topic = to_campfire.topic
        return "No topic" if campfire_topic && campfire_topic.empty?
        campfire_topic
      end

      def topic=(topic)
        to_campfire.topic = topic 
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
        to_campfire.retrieve_messages.inject([]) do |all_messages, message|
          all_messages << message.to_irc unless message.message_type == "TimestampMessage"
          all_messages
        end
      end

    end
  end
end
