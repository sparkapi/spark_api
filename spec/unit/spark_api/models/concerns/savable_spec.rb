require 'spec_helper'

class MyExampleModel < Base
  include Concerns::Savable
  self.prefix = "/test/"
  self.element_name = "example"
end

describe Concerns::Savable, "Model" do

  before :each do
    stub_auth_request
  end

  it "should be creatable" do
    @model = MyExampleModel.new({ :Name => "my name" })
    stub_api_post("/test/example", { :MyExampleModels => [ @model.attributes ] }, "base.json")
    @model.save.should eq(true)
    @model.persisted?.should eq(true)
  end

  it "should be updatable" do
    stub_api_get("/test/example", 'base.json')
    @model = MyExampleModel.first
    @model.Name = "new name"
    stub_api_put("/test/example/1", @model.dirty_attributes)
    @model.save.should eq(true)
    @model.persisted?.should eq(true)
  end

end
