require './spec/spec_helper'

# Sample resource models for testing the base class
class MyExampleModel < Base
  self.element_name = "example"
  self.prefix = "/test/"
end

class MyDefaultModel < Base
end


describe Base, "Base model" do
  describe "class methods" do
    it "should set the element name" do
      MyExampleModel.element_name.should eq("example")
      MyDefaultModel.element_name.should eq("resource")
    end
    it "should set the prefix" do
      MyExampleModel.prefix.should eq("/test/")
      MyDefaultModel.prefix.should eq("/")
    end
    it "should set the path" do
      MyExampleModel.path.should eq("/test/example")
      MyDefaultModel.path.should eq("/resource")
    end
    describe "finders" do
      before(:each) do
        stub_auth_request
        stub_api_get("/test/example", 'base.json')
      end
      it "should get all results" do
        MyExampleModel.get.length.should == 2
      end
      it "should get first result" do
        MyExampleModel.first.Id.should == 1
      end
    end
  end
  
end
