module Flamethrower
  module Irc
    class Channel

      attr_accessor :name, :topic, :users, :modes, :mode

      def initialize(name, campfire_channel=nil)
        @name = name
        @users = []
        @modes = ["t"]
        @campfire_channel = campfire_channel
      end

      def mode
        "+#{@modes.join}"
      end

      def to_campfire
        @campfire_channel
      end

    end
  end
end
