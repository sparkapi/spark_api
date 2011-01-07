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
  

  after(:each) do 
    @proptypes = nil
  end

end
