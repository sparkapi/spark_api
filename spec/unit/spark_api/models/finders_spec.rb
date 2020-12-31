require './spec/spec_helper'

class MyResource < Base
  extend Finders
  self.element_name = "my_resource"
end

describe Finders, "Finders model" do

  before(:each) do
    stub_auth_request
  end

  it "should get first result" do
    stub_api_get("/my_resource", 'finders.json')
    resource = MyResource.first
    expect(resource.Id).to eq(1)
  end

  it "should get last result" do
    stub_api_get("/my_resource", 'finders.json')
    resource = MyResource.last
    expect(resource.Id).to eq(2)
  end

  it "should find one result" do
    stub_api_get("/my_resource", 'finders.json', {
      :_limit => 1,
      :_filter => "Something Eq 'dude'"
    })
    resource = MyResource.find_one(:_filter => "Something Eq 'dude'")
    expect(resource.Id).to eq(1)
  end

  describe "find" do

    it "should throw an error if no argument is passed" do
      stub_api_get("/my_resource/", 'finders.json')
      expect {
        MyResource.find()
      }.to raise_error(ArgumentError)
    end

    it "should throw an error when the first argument is nil" do
      stub_api_get("/my_resource/", 'finders.json', {:_limit => 1})
      expect {
        MyResource.find(nil, {:_limit => 1})
      }.to raise_error(ArgumentError)
    end

  end

end
