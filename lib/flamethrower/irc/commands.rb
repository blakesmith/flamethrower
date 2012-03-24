module Flamethrower
  module Irc
    module Commands
      include Flamethrower::Irc::Codes

      def send_welcome
        send_message reply(RPL_WLCM, ":Welcome to Flamethrower")
      end

      def send_motd
        send_messages do |messages|
          messages << reply(RPL_MOTDSTART, ":MOTD")
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

      def send_rename(from, to)
        send_message ":#{from} NICK #{to}"
      end

      def send_nowaway
        send_message reply(RPL_NOWAWAY, ":You have been marked as being away")
      end

      def send_unaway
        send_message reply(RPL_UNAWAY, ":You are no longer marked as being away")
      end

      def send_who(channel)
        send_messages do |messages|
          channel.users.each do |user|
            messages << reply(RPL_WHOREPLY, "#{channel.name} #{user.nickname} #{user.hostname} localhost #{user.nickname} H :0 #{user.nickname}")
          end
          messages << reply(RPL_ENDOFWHO, "#{channel.name} :/End of /WHO list")
        end
      end

      def send_channel_mode(channel)
        send_message reply(RPL_CHANNELMODEIS, "#{channel.name} #{channel.mode}")
      end

      def send_pong(hostname)
        send_message "PONG :#{hostname}"
      end

      def send_user_mode
        send_message reply(RPL_UMODEIS, @current_user.mode)
      end

      def send_join(user, channel)
        send_message ":#{user.to_s} JOIN #{channel.name}"
      end

      def send_part(user, channel)
        send_message ":#{user.to_s} PART #{channel.name}"
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
