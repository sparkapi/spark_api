require './spec/spec_helper'

describe PropertyTypes do

  it "should respond to get" do
    expect(PropertyTypes).to respond_to(:get)
  end

  describe "/propertytypes", :support do
    before(:each) do
      stub_auth_request
    end

    on_get_it "should return a list of property types" do
      stub_api_get("/propertytypes", "property_types/property_types.json")

      types = PropertyTypes.get
      expect(types).to be_an(Array)
      expect(types.count).to be(6)
    end
  end

  describe "/propertytypes/all", :support do
    before(:each) do
      stub_auth_request
    end

    on_get_it "should return a list of all property types" do
      stub_api_get("/propertytypes/all", "property_types/property_types.json")

      types = PropertyTypes.all
      expect(types).to be_an(Array)
      expect(types.count).to be(6)
    end
  end

end
