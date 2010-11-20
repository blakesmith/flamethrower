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
      item = "one"
      @connection.stream.stub(:each_item).and_yield(item)
      @connection.store_messages
      @connection.messages.pop.should == item
    end
  end

  describe "#retrieve_messages" do
    it "returns all the messages in the message buffer" do
      @connection.messages << "one"
      @connection.messages << "two"
      @connection.retrieve_messages.should == ["one", "two"]
    end

    it "pops the messages from the messages array" do
      @connection.messages << "one"
      @connection.retrieve_messages.should == ["one"]
      @connection.messages.size.should == 0
    end
  end
end
