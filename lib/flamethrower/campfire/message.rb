module Flamethrower
  module Campfire
    class Message
      attr_accessor :body, :user, :room, :message_type, :status

      def initialize(params = {})
        @body = params['body']
        @user = params['user']
        @room = params['room']
        @message_type = params['type']
        @status = "pending"
      end

      def mark_delivered!
        @status = "delivered"
      end

      def mark_failed!
        @status = "failed"
      end
    end
  end
end
