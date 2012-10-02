require 'spec_helper'

class MyExampleModel < Base
  include Concerns::Destroyable
  self.prefix = "/test/"
  self.element_name = "example"
end

describe Concerns::Destroyable, "Destroyable Concern" do

  before :each do
    stub_auth_request
    stub_api_get("/test/example", 'base.json')
    @model = MyExampleModel.first
  end

  it "should not be destroyed" do
    @model.destroyed?.should eq(false)
  end

  it "should be destroyable" do
    stub_api_delete("/test/example/1")
    @model = MyExampleModel.first
    @model.destroy
    @model.destroyed?.should eq(true)
  end

end
