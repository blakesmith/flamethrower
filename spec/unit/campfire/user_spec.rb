require File.join(File.dirname(__FILE__), "../../spec_helper")

describe Flamethrower::Campfire::User do
  before do
    @user = Flamethrower::Campfire::User.new('name' => "Bob Jackson")
  end

  it "should have name" do
    @user.name.should == "Bob Jackson"
  end
end
