module Flamethrower
  class IrcChannel

    attr_accessor :name, :topic, :users, :modes, :mode

    def initialize(name)
      @name = name
      @users = []
      @modes = ["t"]
    end

    def mode
      "+#{@modes.join}"
    end

  end
end
