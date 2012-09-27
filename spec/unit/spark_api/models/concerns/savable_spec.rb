require 'spec_helper'

class MyExampleModel < Base
  include Savable
  self.prefix = "/test/"
  self.element_name = "example"
end

describe Savable, "Savable Concern" do

  before :each do
    stub_auth_request
  end

  it "should be creatable" do
    @model = MyExampleModel.new({ :Name => "my name" })
    stub_api_post("/test/example", { :D => { :Name => "my name" } })
    @model.save.should eq(true)
    @model.persisted.should eq(true)
  end

  it "should be updatable" do
    stub_api_get("/test/example", 'base.json')
    @model = MyExampleModel.first
    @model.Name = "new name"
    stub_api_put("/test/example/1", @model.changed_attributes)
    @model.save.should eq(true)
    @model.persisted.should eq(true)
  end

end
