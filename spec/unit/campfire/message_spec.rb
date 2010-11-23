require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Message do
  before do
    @message = Flamethrower::Campfire::Message.new('body' => "thebody", 'type' => "TextMessage")
  end

  it "should have the message body" do
    @message.body.should == "thebody"
  end

  it "should have the message type" do
    @message.message_type.should == "TextMessage"
  end
end
