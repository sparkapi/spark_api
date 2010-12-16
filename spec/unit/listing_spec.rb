require 'flexmls_api'

describe FlexmlsApi::Listing do

  describe "responds to" do
    it "should respond to find" do
      FlexmlsApi::Listing.respond_to?(:find)
    end

    it "should respond to first" do
      FlexmlsApi::Listing.respond_to?(:first)
    end

    it "should respond to last" do
      FlexmlsApi::Listing.respond_to?(:last)
    end

  end


end
