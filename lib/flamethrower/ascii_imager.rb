module Flamethrower
  module AsciiImager
    DEFAULT_IMAGE_ASCII_SERVICE = "http://skeeter.blakesmith.me"
    DEFAULT_IMAGE_WIDTH = 80

    def image_get(url)
      host = config['service'] || DEFAULT_IMAGE_ASCII_SERVICE
      image_width = config['scale_to_width'] || DEFAULT_IMAGE_WIDTH
      EventMachine::HttpRequest.new(host).get :query => {'image_url' => url, 'width' => image_width}
    end

    def config
      @server.server.ascii_conversion
    end
  end
end
