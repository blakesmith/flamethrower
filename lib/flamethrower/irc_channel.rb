module Flamethrower
  class IrcChannel

    attr_accessor :name, :topic

    def initialize(name)
      @name = name
    end
  end
end
