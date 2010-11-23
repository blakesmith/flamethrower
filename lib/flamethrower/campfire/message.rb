module Flamethrower
  module Campfire
    class Message
      attr_accessor :body, :user, :room, :message_type

      def initialize(params = {})
        @body = params['body']
        @user = params['user']
        @room = params['room']
        @message_type = params['type']
      end
    end
  end
end
