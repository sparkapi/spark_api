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

  describe 'destroyed?' do
    
    it "should not be destroyed" do
      expect(@model.destroyed?).to eq(false)
    end
  end

  describe 'destroy' do

    it "should be destroyable" do
      stub_api_delete("/some/place/20101230223226074201000000")
      @model = MyExampleModel.first
      @model.destroy
      expect(@model.destroyed?).to eq(true)
    end

  end

  describe 'destroy class method' do

    it "allows you to destroy with only the id" do
      stub_api_delete("/test/example/20101230223226074201000000")
      MyExampleModel.destroy('20101230223226074201000000')
      expect_api_request(:delete, "/test/example/20101230223226074201000000").to have_been_made.once
    end

  end

end
