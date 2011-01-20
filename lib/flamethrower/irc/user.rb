module Flamethrower
  module Irc
    class User

      attr_accessor :username, :nickname, :hostname, :realname, :servername, :modes
      attr_accessor :away_message

      def initialize(options={})
        @username = options[:username]
        @nickname = options[:nickname]
        @hostname = options[:hostname]
        @realname = options[:realname]
        @servername = options[:servername]
        @modes = ["i"]
      end

      def nick_set?
        !!@nickname
      end

      def user_set?
        !!@username && !!@hostname && !!@realname && !!@servername
      end

      def mode
        "+#{@modes.join}"
      end

      def to_s
        "#{@nickname}!#{@username}@#{@hostname}"
      end
    end
  end
end
