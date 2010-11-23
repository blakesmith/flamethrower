require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::User do
  before do
    @user = Flamethrower::Campfire::User.new('name' => "Bob Jackson", 'id' => 1234)
  end

  it "should have name" do
    @user.name.should == "Bob Jackson"
  end

  it "should have the user number (id)" do
    @user.number.should == 1234
  end

  describe "#to_irc" do
    it "sets the username and nickname to the campfire user's name" do
      @user.name = "bob"
      @user.to_irc.nickname.should == "bob"
      @user.to_irc.username.should == "bob"
    end

    it "joins spaced names with underscores" do
      @user.to_irc.nickname.should == "Bob_Jackson"
      @user.to_irc.username.should == "Bob_Jackson"
    end
  end
end
