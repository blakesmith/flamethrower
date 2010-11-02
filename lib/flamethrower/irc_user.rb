module Flamethrower
  class IrcUser

    attr_accessor :username, :nickname, :hostname, :realname, :servername

    def initialize(options={})
      @username = options[:username]
      @nickname = options[:nickname]
      @hostname = options[:hostname]
      @realname = options[:realname]
      @servername = options[:servername]
    end

    def nick_set?
      !!@nickname
    end

    def user_set?
      !!@username && !!@hostname && !!@realname && !!@servername
    end
  end
end
