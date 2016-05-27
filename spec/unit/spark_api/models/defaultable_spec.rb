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

    it 'calls find' do
      expect(TestClass).to receive(:find).with('default', {})
      TestClass.default
    end
    
  end
  
  describe 'find' do

    it "adds the id 'default'" do
      allow(TestClass).to receive(:connection).and_return(double(get: [{Id: nil, Name: 'foo'}]))
      default = TestClass.find(TestClass::DEFAULT_ID)
      expect(default.Id).to eq 'default'
    end

    it "doesn't override the id if one is present" do
      allow(TestClass).to receive(:connection).and_return(double(get: [{Id: '5', Name: 'foo'}]))
      expect(TestClass.find(TestClass::DEFAULT_ID).Id).to eq '5'
    end

    it "calls Finders.find when given a normal id" do
      connection = double
      expect(connection).to receive(:get).with("/testclass/5", {foo: true}).and_return([{}])
      allow(TestClass).to receive(:connection).and_return(connection)
      TestClass.find('5', foo: true)
    end
    
  end

end
