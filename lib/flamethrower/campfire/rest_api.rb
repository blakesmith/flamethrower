module Flamethrower
  module Campfire
    module RestApi

      def host
        "https://#{@domain}.campfirenow.com"
      end

      def campfire_get(path, args = {})
        action_log("get", path, nil)
        full_path = host << path
        http = EventMachine::HttpRequest.new(full_path).get(
          :head => {'authorization' => [@token, 'x']},
          :query => args)
        http.errback { on_connection_error("get", path) }
        http
      end

      def campfire_post(path, json=nil)
        action_log("post", path, json)
        full_path = host << path
        params = {:head => {'Content-Type' => 'application/json', 'authorization' => [@token, 'x']}}
        params[:body] = json if json
        http = EventMachine::HttpRequest.new(full_path).post params
        http.errback { on_connection_error("post", path) }
        http
      end

      def campfire_put(path, json=nil)
        action_log("put", path, json)
        full_path = host << path
        params = {:head => {'Content-Type' => 'application/json', 'authorization' => [@token, 'x']}}
        params[:body] = json if json
        http = EventMachine::HttpRequest.new(full_path).put params
        http.errback { on_connection_error("put", path) }
        http
      end

      private

      def action_log(action, path, json)
        ::FLAMETHROWER_LOGGER.debug "Sending #{action.upcase} #{path} with #{json || 'no'} JSON"
      end

      def on_connection_error(action, path)
        @connection.send_message @connection.reply(Flamethrower::Irc::Codes::RPL_MOTD, ":ERROR: Unable to make API call #{action.upcase} #{path}. Check your connection?")
      end

    end
  end
end
