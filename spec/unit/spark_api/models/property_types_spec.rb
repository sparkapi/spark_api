require './spec/spec_helper'

describe PropertyTypes do

  it "should respond to get" do
    PropertyTypes.should respond_to(:get)
  end

  describe "/propertytypes", :support do
    before(:each) do
      stub_auth_request
    end

    on_get_it "should return a list of property types" do
      stub_api_get("/propertytypes", "property_types/property_types.json")

      types = PropertyTypes.get
      types.should be_an(Array)
      types.count.should be(6)
    end
  end

  describe "/propertytypes/all", :support do
    before(:each) do
      stub_auth_request
    end

    on_get_it "should return a list of all property types" do
      stub_api_get("/propertytypes/all", "property_types/property_types.json")

      types = PropertyTypes.all
      types.should be_an(Array)
      types.count.should be(6)
    end
  end

end
