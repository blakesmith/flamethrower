module Flamethrower
  module Campfire
    module RestApi

      def host
        "#{@domain}.campfirenow.com"
      end

      private
      def http
        Net::HTTP.new(host, 443).tap do |connection|
          connection.use_ssl = true
        end
      end

      def campfire_get(path)
        get = Net::HTTP::Get.new(path)
        get.basic_auth @token, 'x'
        http.request(get)
      end

      def campfire_post(path, json=nil)
        put_or_post(Net::HTTP::Post, path, json)
      end

      def campfire_put(path, json=nil)
        put_or_post(Net::HTTP::Put, path, json)
      end

      private

      def put_or_post(request_type, path, json)
        action = request_type.new(path)
        action.basic_auth @token, 'x'
        action.body = json if json
        action.add_field "Content-Type", "application/json"
        http.request(action)
      end

    end
  end
end
