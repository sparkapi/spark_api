require 'spec_helper'

describe ListingMetaTranslations do

  before(:each) do
    stub_auth_request
  end

  context "/flexmls/propertytypes/<PropertyType.MlsCode>/translations", :support do
    
    on_get_it "gets all translations" do
      stub_api_get("/flexmls/propertytypes/A/translations", 'listing_meta_translations/get.json')
      
      translations = ListingMetaTranslations.for_property_type('A')
      expect(translations).to be_an(ListingMetaTranslations)
      expect(translations.StandardFields).to be_an(Hash)
      expect(translations.CustomFields).to be_an(Hash)
    end
    
    on_get_it "doesn't explode if there are no results" do
      stub_api_get("/flexmls/propertytypes/A/translations", 'no_results.json')
      
      translations = ListingMetaTranslations.for_property_type('A')
      expect(translations).to be_an(ListingMetaTranslations)
      expect(translations.StandardFields).to be_an(Hash)
      expect(translations.CustomFields).to be_an(Hash)
    end
  end

end
