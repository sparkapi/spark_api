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

  describe "attribute accessors, setters, and predicates" do
    before(:each) do
      stub_auth_request
      stub_api_get("/test/example", 'base.json')
      @model = MyExampleModel.first
    end

    it "should access existing attributes" do
      @model.Name.should == 'My Example'
    end

    it "should raise errors on access to non-existant attributes" do
      lambda { @model.Nonsense }.should raise_error(NoMethodError)
    end

    it "should set existing attributes" do
      new_name = 'John Jacob Jingleheimerschmidt'
      @model.Name = new_name
      @model.Name.should == new_name
    end

    it "should set non-existant attributes" do
      nonsense = 'nonsense'
      @model.Nonsense = nonsense
      @model.Nonsense.should == nonsense
    end

    it "should return a boolean for a predicate for an existing attribute" do
      @model.Name?.should satisfy { |p| [true, false].include?(p) }
    end

    it "should raise an Error for a predicate for a non-existant attribute" do
      lambda { @model.Nonsense? }.should raise_error(NoMethodError)
    end

    it "should repond_to existing attributes" do
      @model.should respond_to(:Name)
    end

    it "should not respond_to non-existant attributes" do
      @model.should_not respond_to(:Nonsense)
    end

    it "should respond_to a setter for an existing attribute" do
      @model.should respond_to(:Name=)
    end

    it "should respond_to a setter for a non-existant attribute" do
      @model.should respond_to(:Nonsense=)
    end

    it "should respond_to a predicate for an existing attribute" do
      @model.should respond_to(:Name?)
    end

    it "should not respond_to a predicate for a non-existant attribute" do
      @model.should_not respond_to(:Nonsense?)
    end

    it "should respond_to methods inherited from parent classes" do
      @model.should respond_to(:freeze)
    end

  end

end
