require './spec/spec_helper'

class MyResource < Base
  extend Finders
  self.element_name = "my_resource"
end

describe Finders, "Finders model" do

  before(:each) do
    stub_auth_request
    stub_api_get("/my_resource", 'finders.json')
  end

  it "should get first result" do
    resource = MyResource.first
    resource.Id.should eq(1)
  end

  it "should get last result" do
    resource = MyResource.last
    resource.Id.should eq(2)
  end

end
