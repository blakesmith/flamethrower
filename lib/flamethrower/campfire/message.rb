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

      def to_irc
        case message_type
        when "TextMessage"
          Flamethrower::Message.new(":#{@user.to_irc.to_s} PRIVMSG #{@room.to_irc.name} :#{@body}")
        when "EnterMessage"
          Flamethrower::Message.new(":#{@user.to_irc.to_s} JOIN #{@room.to_irc.name}")
        end
      end
    end
  end
end
