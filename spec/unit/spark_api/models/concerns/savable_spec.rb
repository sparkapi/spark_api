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
    expect(@model.save).to eq(true)
    expect(@model.persisted?).to eq(true)
    expect(s).to have_been_requested
  end

  it "should be updatable" do
    stub_api_get("/test/example", 'base.json')
    @model = MyExampleModel.first
    @model.Name = "new name"
    s = stub_api_put("/some/place/20101230223226074201000000", @model.dirty_attributes)
    expect(@model.save).to eq(true)
    expect(@model.persisted?).to eq(true)
    expect(s).to have_been_requested
  end

  it "should allow the pluralize method to be overriden" do
    @model = MyOtherExampleModel.new({ :Name => "my name" })
    s = stub_api_post("/test/example", { :MyOtherExampleModelThatIsPluralized => [ @model.attributes ] }, "base.json")
    expect(@model.save).to eq(true)
    expect(@model.persisted?).to eq(true)
    expect(s).to have_been_requested
  end

  it "should not pluralize the resource if it already is" do
    @model = MyPluralizedModels.new({ :Name => "my name" })
    s = stub_api_post("/test/example", { :MyPluralizedModels => [ @model.attributes ] }, "base.json")
    expect(@model.save).to eq(true)
    expect(@model.persisted?).to eq(true)
    expect(s).to have_been_requested
  end

  it "merges any attributes that come back in the response" do
    @model = MyExampleModel.new({ :Name => "my name" })
    s = stub_api_post("/test/example", { :MyExampleModels => [ @model.attributes ] }, "base.json")
    expect(@model.save).to eq(true)
    expect(@model.persisted?).to eq(true)
    expect(@model.Id).to eq(1)
    expect(@model.ResourceUri).to eq("/v1/some/place/20101230223226074201000000")
    expect(@model.Name).to eq("My Example")
    expect(@model.Test).to eq(true)
    expect(s).to have_been_requested
  end

  describe "update_attributes" do
    it "loads the attributes" do
      model = MyExampleModel.new
      new_attributes = {Name: "My Name"}
      expect(model).to receive(:load).with(new_attributes, {})
      expect(model).to receive(:save!)
      model.update_attributes(new_attributes)
    end
  end

end
