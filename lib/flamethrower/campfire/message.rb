module Flamethrower
  module Campfire
    class Message
      attr_accessor :body, :user, :room

      def initialize(params = {})
        @body = params['body']
        @user = params['user']
        @room = params['room']
      end
    end
  end
end
