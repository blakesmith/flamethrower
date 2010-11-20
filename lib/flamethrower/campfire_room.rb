module Flamethrower
  class CampfireRoom
    attr_reader :stream
    attr_accessor :messages, :number, :name, :topic

    def initialize(token, params = {})
      @token = token
      @messages = Queue.new
      @number = params['id']
      @name = params['name']
      @topic = params['topic']
    end

    def connect
      @stream = Twitter::JSONStream.connect(:path => "/room/#{@number}/live.json", 
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
