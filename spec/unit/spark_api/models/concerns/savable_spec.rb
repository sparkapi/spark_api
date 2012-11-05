require 'spec_helper'

class MyExampleModel < Base
  include Concerns::Savable
  self.prefix = "/test/"
  self.element_name = "example"
end

class MyOtherExampleModel < Base
  include Concerns::Savable
  self.prefix = "/test/"
  self.element_name = "example"
  private
  def resource_pluralized
    "MyOtherExampleModelThatIsPluralized"
  end
end

class MyPluralizedModels < Base
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
    s = stub_api_post("/test/example", { :MyExampleModels => [ @model.attributes ] }, "base.json")
    @model.save.should eq(true)
    @model.persisted?.should eq(true)
    s.should have_been_requested
  end

  it "should be updatable" do
    stub_api_get("/test/example", 'base.json')
    @model = MyExampleModel.first
    @model.Name = "new name"
    s = stub_api_put("/test/example/1", @model.dirty_attributes)
    @model.save.should eq(true)
    @model.persisted?.should eq(true)
    s.should have_been_requested
  end

  it "should allow the pluralize method to be overriden" do
    @model = MyOtherExampleModel.new({ :Name => "my name" })
    s = stub_api_post("/test/example", { :MyOtherExampleModelThatIsPluralized => [ @model.attributes ] }, "base.json")
    @model.save.should eq(true)
    @model.persisted?.should eq(true)
    s.should have_been_requested
  end

  it "should not pluralize the resource if it already is" do
    @model = MyPluralizedModels.new({ :Name => "my name" })
    s = stub_api_post("/test/example", { :MyPluralizedModels => [ @model.attributes ] }, "base.json")
    @model.save.should eq(true)
    @model.persisted?.should eq(true)
    s.should have_been_requested
  end

end
