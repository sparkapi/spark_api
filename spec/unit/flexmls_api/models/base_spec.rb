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

  describe "attribute access" do
    before(:each) do
      stub_auth_request
      stub_api_get("/test/example", 'base.json')
      @model = MyExampleModel.first
    end

    it "should access valid attributes" do
      @model.Id.should == 1
      @model.Name.should == 'My Example'
      @model.Test.should be_true
    end

    it "should repond_to valid attributes" do
      @model.should respond_to(:Id)
      @model.should respond_to(:Name)
      @model.should respond_to(:Test)
    end

    it "should raise errors on access to invalid attributes" do
      lambda { @model.Nonsense }.should raise_error(NoMethodError)
      lambda { @model.Heidi }.should raise_error(NoMethodError)
      lambda { @model.Named }.should raise_error(NoMethodError)
      lambda { @model.Testy }.should raise_error(NoMethodError)
    end

    it "should not respond_to invalid attributes" do
      @model.should_not respond_to(:MlsId)
      @model.should_not respond_to(:Named)
      @model.should_not respond_to(:Testy)
    end

    it "should respond to any setter or predicate" do
      @model.should respond_to(:Id?)
      @model.should respond_to(:Name?)
      @model.should respond_to(:Test?)

      @model.should respond_to(:Id=)
      @model.should respond_to(:Name=)
      @model.should respond_to(:Test=)

      @model.should respond_to(:MlsId?)
      @model.should respond_to(:Named?)
      @model.should respond_to(:Testy?)

      @model.should respond_to(:MlsId=)
      @model.should respond_to(:Named=)
      @model.should respond_to(:Testy=)
    end
  end
  
end
