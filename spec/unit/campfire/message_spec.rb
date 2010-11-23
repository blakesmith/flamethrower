require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::Message do
  before do
    @message = Flamethrower::Campfire::Message.new('body' => "thebody")
  end

  it "should have the message body" do
    @message.body.should == "thebody"
  end
end
