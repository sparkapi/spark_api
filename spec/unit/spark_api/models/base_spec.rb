require './spec/spec_helper'

# Sample resource models for testing the base class
module SparkApi
  module Models
    class MyExampleModel < Base
      self.element_name = "example"
      self.prefix = "/test/"
    end
  end
end

class MyDefaultModel < Base
end

describe MyExampleModel, "Example model" do

  before(:each) do
    stub_auth_request
    stub_api_get("/test/example", 'base.json')
    @model = MyExampleModel.first
  end

  it "should be persisted" do
    expect(@model.persisted?).to eq(true)
  end

  it "should not be persisted" do
    @new_model = MyExampleModel.new()
    expect(@new_model.persisted?).to eq(false)
  end

  it "should parse and return ResourceUri without v1" do
    expect(@model.resource_uri).to eq("/some/place/20101230223226074201000000")
  end

  it "should parse and return the correct path for a persisted resource" do
    expect(@model.path).to eq("/some/place")
  end

  it "should parse and return the correct path" do
    @model = MyExampleModel.new
    expect(@model.path).to eq("/test/example")
  end

  it "should parse and return the correct path for resource with a parent" do
    @model = MyExampleModel.new
    @model.parent = Contact.new({ :Id => "20101230223226074201000000" })
    expect(@model.path).to eq("/contacts/20101230223226074201000000/test/example")
  end

end

describe Base, "Base model" do

  describe "class methods" do
    it "should set the element name" do
      expect(MyExampleModel.element_name).to eq("example")
      expect(MyDefaultModel.element_name).to eq("resource")
    end
    it "should set the prefix" do
      expect(MyExampleModel.prefix).to eq("/test/")
      expect(MyDefaultModel.prefix).to eq("/")
    end
    it "should set the path" do
      expect(MyExampleModel.path).to eq("/test/example")
      expect(MyDefaultModel.path).to eq("/resource")
    end
    describe "finders" do
      before(:each) do
        stub_auth_request
        stub_api_get("/test/example", 'base.json')
      end
      it "should get all results" do
        expect(MyExampleModel.get.length).to eq(2)
      end
      it "should get first result" do
        expect(MyExampleModel.first.Id).to eq(1)
        expect(MyExampleModel.first.Id).to eq(MyExampleModel.first.id)
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
      expect(@model.Name).to eq('My Example')
    end

    it "should raise errors on access to non-existant attributes" do
      expect { @model.Nonsense }.to raise_error(NoMethodError)
    end

    it "should set existing attributes" do
      new_name = 'John Jacob Jingleheimerschmidt'
      @model.Name = new_name
      expect(@model.Name).to eq(new_name)
    end

    it "should set non-existant attributes" do
      nonsense = 'nonsense'
      @model.Nonsense = nonsense
      expect(@model.Nonsense).to eq(nonsense)
    end

    it "should return a boolean for a predicate for an existing attribute" do
      expect(@model.Name?).to satisfy { |p| [true, false].include?(p) }
    end

    it "should return a boolean for whether or not a model is persisted through the api" do
      expect(@model.persisted?).to satisfy { |p| [true, false].include?(p) }
    end

    it "should raise an Error for a predicate for a non-existant attribute" do
      expect { @model.Nonsense? }.to raise_error(NoMethodError)
    end

    it "should repond_to existing attributes" do
      expect(@model).to respond_to(:Name)
    end

    it "should not respond_to non-existant attributes" do
      expect(@model).not_to respond_to(:Nonsense)
    end

    it "should respond_to a setter for an existing attribute" do
      expect(@model).to respond_to(:Name=)
    end

    it "should respond_to a setter for a non-existant attribute" do
      expect(@model).to respond_to(:Nonsense=)
    end

    it "should respond_to a predicate for an existing attribute" do
      expect(@model).to respond_to(:Name?)
    end

    it "should not respond_to a predicate for a non-existant attribute" do
      expect(@model).not_to respond_to(:Nonsense?)
    end

    it "should respond_to methods inherited from parent classes" do
      expect(@model).to respond_to(:freeze)
    end

    it "should respond_to a will_change! method for an existing attribute" do
      expect(@model).to respond_to(:Name_will_change!)
    end

    it "should not respond_to a will_change! method for a non-existant attribute" do
      expect(@model).not_to respond_to(:Nonsense_will_change!)
    end

  end

  describe "to_partial_path" do
    it "should return the partial path" do
      model = MyExampleModel.new()
      expect(model.to_partial_path).to eq("my_example_models/my_example_model")
    end
  end

end
