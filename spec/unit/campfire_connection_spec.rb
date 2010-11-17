require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::CampfireConnection do
  before do
    @connection = Flamethrower::CampfireConnection.new(1234, "mytoken")
  end

  describe "#connect" do
    it "initializes the twitter jsonstream with the right options" do
      Twitter::JSONStream.should_receive(:connect).with(:path => "/room/1234/live.json", :host => "streaming.campfirenow.com", :auth => "mytoken:x")
      @connection.connect
    end
  end

  describe "#store_messages" do
    it "iterates over each stream item and sends to the campfire dispatcher" do
      items = ["one"]
      @connection.stream.stub(:each_item).and_yield(items.first)
      @connection.store_messages
      @connection.messages.should == items
    end
  end
end
