require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::Message do
  describe "USER" do
    it "should break a string into command and params" do
      message = Flamethrower::Message.new("USER guest tolmoon tolsun :Ronnie Reagan\r\n")
      message.parse.should == {:command => "USER", :params => ["guest", "tolmoon", "tolsun", "Ronnie Reagan"]}
    end

    it "strips out the prefix character from the message" do
      message = Flamethrower::Message.new("COMMAND :Ronnie Reagan\r\n")
      message.send(:strip_prefixes, [":Ronnie", "Reagan"]).should == ["Ronnie Reagan"]
    end
  end
end
