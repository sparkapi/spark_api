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

  it "should return an array of the attributes that have been changed" do
    @model.changed.should eq(["Name"])
  end

  it "should return a hash diff of current changes on a model" do
    @model.changes.should eq({
      "Name" => ["some old name", "a new name"]
    })
  end

  it "should return previously changed attributes after save" do
    stub_api_post('/test/example', { :MyExampleModels => [ @model.attributes ] }, 'base.json')
    @model.save
    @model.previous_changes.should eq({
    })
  end

  it "should return changed attributes with old values" do
    @model.changed_attributes.should eq({
      "Name" => "some old name"
    })
  end

  it "should return changed attributes with new values" do
    @model.dirty_attributes.should eq({
      "Name" => "a new name"
    })
  end

end
