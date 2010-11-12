require 'rubygems'
require 'json'
 
# sudo gem install twitter-stream -s http://gemcutter.org
# http://github.com/voloko/twitter-stream
require 'twitter/json_stream'
 
$messages = []
 
def run_client
  token = '0c79b4617ab40cc395868b94fe6f0ae0b5db4a4c'
  room_id = 347348
   
  options = {
    :path => "/room/#{room_id}/live.json",
    :host => 'streaming.campfirenow.com',
    :auth => "#{token}:x"
  }

  Thread.new do
    EventMachine::run do
      stream = Twitter::JSONStream.connect(options)
     
      stream.each_item do |item|
        $messages << JSON.parse(item)
      end
     
      stream.on_error do |message|
        puts "ERROR:#{message.inspect}"
      end
     
      stream.on_max_reconnects do |timeout, retries|
        puts "Tried #{retries} times to connect."
        exit
      end
    end
  end
end
