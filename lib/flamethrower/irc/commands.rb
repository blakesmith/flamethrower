module Flamethrower
  module Irc
    module Commands
      include Flamethrower::Irc::Codes

      def send_motd
        send_messages do |messages|
          messages << reply(RPL_MOTDSTART, ":MOTD")
          messages << reply(RPL_MOTD, ":Welcome to Flamethrower")
          messages << reply(RPL_MOTD, ":Fetching channel list from campfire...")
        end
      end

      def send_topic(channel)
        send_message reply(RPL_TOPIC, "#{channel.name} :#{channel.topic}")
      end

      def send_channel_list
        send_messages do |messages|
          messages << reply(RPL_MOTD, ":Active channels:")
          @irc_channels.each do |channel|
            messages << reply(RPL_MOTD, ":#{channel.name} - #{channel.topic}")
          end
          messages << reply(RPL_ENDOFMOTD, ":End of channel list /MOTD")
        end
      end

      def send_userlist(channel)
        send_messages do |messages|
          display_users = (["@#{@current_user.nickname}"] + channel.users.map(&:nickname)).join("\s")
          messages << reply(RPL_NAMEREPLY, "= #{channel.name} :#{display_users}")
          messages << reply(RPL_ENDOFNAMES, "#{channel.name} :/End of /NAMES list")
        end
      end

      def send_channel_mode(channel)
        send_message reply(RPL_CHANNELMODEIS, "#{channel.name} #{channel.mode}")
      end

      def send_user_mode
        send_message reply(RPL_UMODEIS, @current_user.mode)
      end

      def reply(code, message)
        ":#{@current_user.hostname} #{code} #{@current_user.nickname} #{message}"
      end

      def error(code)
        ":#{@current_user.hostname} #{code}"
      end
    end
  end
end
