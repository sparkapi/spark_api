require './spec/spec_helper'

describe PropertyTypes do
  before(:each) do
    @proptypes = PropertyTypes.new({
      "MlsName"=>"Residential",
      "MlsCode"=>"A"
    })
  end

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

  after(:each) do
    @proptypes = nil
  end

end
