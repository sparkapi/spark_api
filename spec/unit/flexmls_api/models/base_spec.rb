require './spec/spec_helper'

# Sample resource models for testing the base class
class MyExampleModel < Base
  self.element_name = "example"
  self.prefix = "/test/"
  def self.connection
    @connection ||= Base.connection
  end
  def self.connection=(con)
    @connection = con
  end
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
      before(:all) do
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/v1/test/example?ApiSig=0637dccf93be3774c9c7c554bb0b1d9a&AuthToken=1234') { [200, {}, '{"D": {
            "Success": true, 
            "Results": [{
              "Id": 1,
              "Name": "My Example", 
              "Test": true
            },
            {
              "Id": 2, 
              "Name": "My Example2", 
              "Test": false
            }]}
            }'] 
          }
        end
        MyExampleModel.connection = mock_client(stubs)
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
