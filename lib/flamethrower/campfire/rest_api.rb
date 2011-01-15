module Flamethrower
  module Campfire
    module RestApi

      def host
        "https://#{@domain}.campfirenow.com"
      end

      private
      def http
        EventMachine::HttpRequest.new(host)
        #Net::HTTP.new(host, 443).tap do |connection|
        #  connection.use_ssl = true
        #end
      end

      def campfire_get(path)
        full_path = host << path
        EventMachine::HttpRequest.new(full_path).get :head => {'authorization' => [@token, 'x']}
      end

      def campfire_post(path, json=nil)
      #  put_or_post(Net::HTTP::Post, path, json)
        full_path = host << path
        EventMachine::HttpRequest.new(full_path).post :head => {'Content-Type' => 'application/json', 'authorization' => [@token, 'x']}
      end

      def campfire_put(path, json=nil)
        full_path = host << path
        EventMachine::HttpRequest.new(full_path).put :head => {'Content-Type' => 'application/json', 'authorization' => [@token, 'x']}
      end

      #def put_or_post(request_type, path, json)
      #  action = request_type.new(path)
      #  action.basic_auth @token, 'x'
      #  action.body = json if json
      #  action.add_field "Content-Type", "application/json"
      #  http.request(action)
      #end

    end
  end
end
