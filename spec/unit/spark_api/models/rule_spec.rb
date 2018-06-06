require './spec/spec_helper'

describe Rule do

  describe 'for_property_type' do
   
    on_get_it "should get documents for a listing" do
      stub_auth_request
      stub_api_get('/listings/rules/propertytypes/A','rules/get.json')

      rules = Rule.for_property_type('A')
      rules.should be_an(Array)
      rules.length.should == 2
    end

  end

end
