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

    end
  end
end
