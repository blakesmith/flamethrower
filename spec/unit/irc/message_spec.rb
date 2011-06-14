require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Irc::Message do
  it "returns the params from the @message hash" do
    message = Flamethrower::Irc::Message.new("COMMAND param")
    message.command.should == "COMMAND"
  end

  it "returns the command from the @message hash" do
    message = Flamethrower::Irc::Message.new("COMMAND param")
    message.parameters.should == ["param"] 
  end

  describe "USER" do
    it "should break a string into command and params" do
      message = Flamethrower::Irc::Message.new("USER guest tolmoon tolsun :Ronnie Reagan")
      message.parse.should == {:command => "USER", :params => ["guest", "tolmoon", "tolsun", "Ronnie Reagan"]}
    end

    it "strips out the prefix character from the message" do
      message = Flamethrower::Irc::Message.new("COMMAND :Ronnie Reagan")
      message.send(:strip_prefixes, [":Ronnie", "Reagan"]).should == ["Ronnie Reagan"]
    end
  end

  describe "#to_s" do
    it "returns the irc message" do
      message = Flamethrower::Irc::Message.new("COMMAND param")
      message.to_s.should == "COMMAND param"
    end
  end
end
