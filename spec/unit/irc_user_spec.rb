require File.join(File.dirname(__FILE__), "../spec_helper")

describe Flamethrower::IrcUser do
  before do
    @user = Flamethrower::IrcUser.new
  end

  context "storing initial arguments" do
    before do
      @initial_user = Flamethrower::IrcUser.new :user => "user", :nick => "nick", :host => "host", :realname => "realname"
    end

    it "should have user" do
      @initial_user.user.should == "user"
    end

    it "should have nick" do
      @initial_user.nick.should == "nick"
    end

    it "should have host" do
      @initial_user.host.should == "host"
    end

    it "should have realname" do
      @initial_user.realname.should == "realname"
    end
  end

end
