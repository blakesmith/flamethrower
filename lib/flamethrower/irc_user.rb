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
  end
end
