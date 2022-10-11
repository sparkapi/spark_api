require 'spec_helper'

describe Defaultable do

  module SparkApi
    module Models
      class TestClass < Base
        extend Finders
        include Defaultable
        self.element_name = 'testclass'
      end
    end
  end

  describe 'default' do

    it 'returns an instance of the class' do
      allow(TestClass).to receive(:connection).and_return(double(get: [{"Name" => 'foo'}]))
      expect(TestClass.default).to be_a TestClass
    end

    it 'returns nil when there are no results' do
      allow(TestClass).to receive(:connection).and_return(double(get: []))
      expect(TestClass.default).to be nil
    end

    it "assigns the default id to the instance if it doesn't have an id" do
      allow(TestClass).to receive(:connection).and_return(double(get: [{"Name" => 'foo'}]))
      expect(TestClass.default.Id).to eq TestClass::DEFAULT_ID
    end

    it "doesn't override the id if one is present" do
      allow(TestClass).to receive(:connection).and_return(double(get: [{"Id" => '5', "Name" => 'foo'}]))
      expect(TestClass.default.Id).to eq '5'
    end
    
  end
  
  describe 'find' do

    it "calls 'default' when given the default id" do
      expect(TestClass).to receive(:default)
      TestClass.find(TestClass::DEFAULT_ID)
    end

    it "passes options to 'default'" do
      args = { foo: true }
      expect(TestClass).to receive(:default).with(args)
      TestClass.find(TestClass::DEFAULT_ID, args)
    end

    it "calls Finders.find when given a normal id" do
      connection = double
      expect(connection).to receive(:get).with("/testclass/5", {foo: true}).and_return([{}])
      allow(TestClass).to receive(:connection).and_return(connection)
      TestClass.find('5', foo: true)
    end
    
  end

end
