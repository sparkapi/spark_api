require 'spec_helper'

describe ListingMetaTranslations do

  before(:each) do
    stub_auth_request
  end

  context "/flexmls/propertytypes/<PropertyType.MlsCode>/translations", :support do
    
    on_get_it "gets all translations" do
      stub_api_get("/flexmls/propertytypes/A/translations", 'listing_meta_translations/get.json')
      
      translations = ListingMetaTranslations.for_property_type('A')
      translations.should be_an(ListingMetaTranslations)
      translations.StandardFields.should be_an(Hash)
      translations.CustomFields.should be_an(Hash)
    end
    
    on_get_it "doesn't explode if there are no results" do
      stub_api_get("/flexmls/propertytypes/A/translations", 'no_results.json')
      
      translations = ListingMetaTranslations.for_property_type('A')
      translations.should be_an(ListingMetaTranslations)
      translations.StandardFields.should be_an(Hash)
      translations.CustomFields.should be_an(Hash)
    end
  end

end
