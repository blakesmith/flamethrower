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
        post = Net::HTTP::Post.new(path)
        post.basic_auth @token, 'x'
        post.body = json if json
        post.add_field "Content-Type", "application/json"
        http.request(post)
      end

    end
  end
end
