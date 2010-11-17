module Flamethrower
  class CampfireConnection
    attr_reader :stream, :messages

    def initialize(room_num, token)
      @room_num = room_num
      @token = token
      @messages = []
      @mutex = Mutex.new
    end

    def connect
      @stream = Twitter::JSONStream.connect(:path => "/room/#{@room_num}/live.json", 
                                  :host => "streaming.campfirenow.com", 
                                  :auth => "#{@token}:x")
    end

    def store_messages
      @stream.each_item do |item| 
        @mutex.synchronize do
          @messages << item 
        end
      end
    end
  end
end
