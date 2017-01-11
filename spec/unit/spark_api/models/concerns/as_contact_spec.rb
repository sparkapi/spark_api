require 'spec_helper'

class AsContactTestClass < SparkApi::Models::Base 
  include Concerns::AsContact
  extend Finders
  self.element_name="testclass"
end

describe "AsContact" do

  describe "self.as_contact" do 

    it "prepends '/contacts/id' to the path" do 
      expect(AsContactTestClass.as_contact(5).path).to eq("/contacts/5/testclass")
    end

    it "accepts a contact object as the argument" do
      expect(AsContactTestClass.as_contact(Contact.new(Id: 5)).path).to eq("/contacts/5/testclass")
    end

    it "does not permanently modify the path" do 
      expect(AsContactTestClass.path).to eq("/testclass")
      expect(AsContactTestClass.as_contact(5).path).to eq("/contacts/5/testclass")
      expect(AsContactTestClass.path).to eq("/testclass")
    end
    
    it "still responds to find" do 
      expect(AsContactTestClass.as_contact(5)).to respond_to(:find)
    end

    it "doesn't interfere with is_a?" do
      expect(AsContactTestClass.new.is_a?(AsContactTestClass)).to be true
      expect(AsContactTestClass.as_contact(5).new.is_a?(AsContactTestClass)).to be true
    end
    
  end

  describe "as_contact" do

    it "prepends '/contacts/id' to the path" do 
      test_class = AsContactTestClass.new
      expect(test_class.as_contact(5).path).to eq("/contacts/5/testclass")
    end

    it "accepts a contact object as the argument" do
      test_class = AsContactTestClass.new
      expect(test_class.as_contact(Contact.new(Id: 5)).path).to eq("/contacts/5/testclass")
    end

    it "doesn't modify later instances" do
      test_class = AsContactTestClass.new
      expect(test_class.as_contact(5).path).to eq("/contacts/5/testclass")
      test_class_2 = AsContactTestClass.new
      expect(test_class_2.path).to eq("/testclass")
    end

    it "doesn't mess up other attributes" do
      test_class = AsContactTestClass.new(name: "the test")
      expect(test_class.as_contact(5).name).to eq("the test")
    end

  end

end
