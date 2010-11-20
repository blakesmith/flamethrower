module Flamethrower
  class CampfireRoom
    attr_reader :stream
    attr_accessor :messages

    def initialize(room_num, token)
      @room_num = room_num
      @token = token
      @messages = Queue.new
    end

    def connect
      @stream = Twitter::JSONStream.connect(:path => "/room/#{@room_num}/live.json", 
                                  :host => "streaming.campfirenow.com", 
                                  :auth => "#{@token}:x")
    end

    def store_messages
      @stream.each_item do |item| 
	@messages << item 
      end
    end

    def retrieve_messages
      Array.new.tap do |new_array|
	until @messages.empty?
	  new_array << @messages.pop
	end
      end
    end
  end
end
