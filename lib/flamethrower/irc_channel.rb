module Flamethrower
  class IrcChannel

    attr_accessor :name, :topic, :users

    def initialize(name)
      @name = name
      @users = []
    end
  end
end
