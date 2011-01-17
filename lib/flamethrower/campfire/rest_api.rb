module Flamethrower
  module Campfire
    module RestApi

      def host
        "https://#{@domain}.campfirenow.com"
      end

      private
      def http
        EventMachine::HttpRequest.new(host)
      end

      def campfire_get(path)
        action_log("get", path, nil)
        full_path = host << path
        EventMachine::HttpRequest.new(full_path).get :head => {'authorization' => [@token, 'x']}
      end

      def campfire_post(path, json=nil)
        action_log("post", path, json)
        full_path = host << path
        params = {:head => {'Content-Type' => 'application/json', 'authorization' => [@token, 'x']}}
        params[:body] = json if json
        http = EventMachine::HttpRequest.new(full_path).post params
      end

      def campfire_put(path, json=nil)
        action_log("put", path, json)
        full_path = host << path
        params = {:head => {'Content-Type' => 'application/json', 'authorization' => [@token, 'x']}}
        params[:body] = json if json
        EventMachine::HttpRequest.new(full_path).put params
      end

      private

      def action_log(action, path, json)
        ::FLAMETHROWER_LOGGER.debug "Sending #{action.upcase} #{path} with #{json || 'no'} JSON"
      end

    end
  end
end
