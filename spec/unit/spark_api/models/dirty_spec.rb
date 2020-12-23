require 'spec_helper'

class MyExampleModel < Base
  include Concerns::Savable
  self.prefix = "/test/"
  self.element_name = "example"
end

describe Dirty do

  before :each do
    stub_auth_request
    @model = MyExampleModel.new(:Name => "some old name")
    @model.Name = "a new name"
  end

  it "lets you know if you've changed any attributes" do
    expect(@model.changed?).to be true
  end

  it "should return an array of the attributes that have been changed" do
    expect(@model.changed).to eq(["Name"])
  end

  it "should return a hash diff of current changes on a model" do
    expect(@model.changes).to eq({
      "Name" => ["some old name", "a new name"]
    })
  end

  it "should return previously changed attributes after save" do
    stub_api_post('/test/example', { :MyExampleModels => [ @model.attributes ] }, 'base.json')
    @model.save
    expect(@model.previous_changes).to eq({
    })
  end

  it "should return changed attributes with old values" do
    expect(@model.changed_attributes).to eq({
      "Name" => "some old name"
    })
  end

  it "should return changed attributes with new values" do
    expect(@model.dirty_attributes).to eq({
      "Name" => "a new name"
    })
  end

  it "does not mark attributes dirty when initialized" do
    @model = MyExampleModel.new(:Name => "some sort of name")
    expect(@model.attributes.size).to eq(1)
    expect(@model.changed_attributes).to eq({})
    expect(@model.dirty_attributes).to eq({})
  end

  it "marks attributes dirty that are loaded later" do
    @model.load(:Name => "some sort of name")
    expect(@model.attributes.size).to eq(1)
    expect(@model.changed_attributes).to eq({"Name"=>"some old name"})
    expect(@model.dirty_attributes).to eq({"Name"=>"some sort of name"})
  end

end
