module Flamethrower
  module Campfire
    class Message
      attr_accessor :body, :user, :room, :direction, :message_type, :status, :retry_at, :image_converted, :user_id

      RETRY_SECONDS = 15

      def initialize(params = {})
        @body = params['body']
        @user = params['user']
        @room = params['room']
        @user_id = set_user_id(params)
        @message_type = params['type']
        @direction = params['direction']
        @status = "pending"
        @image_converted = false
      end

      def mark_delivered!
        @status = "delivered"
      end

      def mark_failed!
        @status = "failed"
        @retry_at = Time.now + RETRY_SECONDS
      end

      def mark_pending!
        @status = "pending"
      end

      def failed?
        @status == "failed"
      end

      def pending?
        @status == "pending"
      end

      def outbound?
        @direction == "outbound"
      end

      def inbound?
        @direction == "inbound"
      end

      def needs_image_conversion?
        has_images? && !@image_converted
      end

      def image_urls
        if @body
          @body.scan(/(https?:\/\/.+?\.(?:jpg|jpeg|gif|png))/i).flatten
        else
          []
        end
      end

      def has_images?
        image_urls.size > 0
      end

      def set_ascii_image(str)
        @body << "\n#{str}"
        @message_type = "PasteMessage"
        @image_converted = true
      end

      def to_irc
        case message_type
        when "TextMessage"
          irc_string = ":#{@user.to_irc.to_s} PRIVMSG #{@room.to_irc.name} :#{@body}"
        when "EnterMessage"
          irc_string = ":#{@user.to_irc.to_s} JOIN #{@room.to_irc.name}"
        when "KickMessage"
          irc_string = ":#{@user.to_irc.to_s} PART #{@room.to_irc.name}"
        when "LeaveMessage"
          irc_string = ":#{@user.to_irc.to_s} PART #{@room.to_irc.name}"
        when "PasteMessage"
          irc_string = format_paste_message
        else
          return
        end
        Flamethrower::Irc::Message.new(irc_string)
      end

      private

      def format_paste_message
        lines = @body.split("\n")
        message = lines.inject(Array.new) do |array, line|
          array << ":#{@user.to_irc.to_s} PRIVMSG #{@room.to_irc.name} :#{line}"
        end
        message.join("\r\n")
      end

      def set_user_id(params)
        if params['user_id']
          params['user_id']
        elsif params['user'].is_a?(User)
          params['user'].number
        elsif params['user'] && params['user'].is_a?(Hash)
          params['user']['id']
        else
          nil
        end
      end
    end
  end
end
