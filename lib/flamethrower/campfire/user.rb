module Flamethrower
  module Campfire
    class User
      attr_accessor :name, :number

      def initialize(params = {})
        @name = params['name']
        @number = params['id']
      end

      def to_irc
        nick = @name.gsub("\s", "_")
        @irc_user ||= Flamethrower::Irc::User.new(:username => nick, :nickname => nick)
      end
    end
  end
end
