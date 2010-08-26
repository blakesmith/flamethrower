module Flamethrower
  class IrcUser

    attr_accessor :user, :nick, :host, :realname

    def initialize(options={})
      @user = options[:user]
      @nick = options[:nick]
      @host = options[:host]
      @realname = options[:realname]
    end
  end
end
