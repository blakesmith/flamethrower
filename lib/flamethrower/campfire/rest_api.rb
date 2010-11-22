module Flamethrower
  module Campfire
    module RestApi

      def host
        "#{@domain}.campfirenow.com"
      end

      private
      def http
        Net::HTTP.new(host, 443).tap do |http|
          http.use_ssl = true
        end
      end

      def campfire_get(path)
        get = Net::HTTP::Get.new(path)
        get.basic_auth @token, 'x'
        http.request(get)
      end

    end
  end
end
