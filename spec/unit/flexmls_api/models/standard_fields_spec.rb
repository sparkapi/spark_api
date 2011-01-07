require './spec/spec_helper'

describe StandardFields do
  before(:each) do 
    @stdfields = StandardFields.new({
      "StreetNumber"=>{"Searchable"=>false}, 
      "ListingId"=>{"Searchable"=>true}, 
      "City"=>{"Searchable"=>true}, 
      "Longitude"=>{"Searchable"=>false}, 
      "StreetName"=>{"Searchable"=>false}, 
      "YearBuilt"=>{"Searchable"=>true}, 
      "BuildingAreaTotal"=>{"Searchable"=>true}, 
      "PublicRemarks"=>{"Searchable"=>false}, 
      "PostalCode"=>{"Searchable"=>true}, 
      "ListPrice"=>{"Searchable"=>true}, 
      "BathsThreeQuarter"=>{"Searchable"=>true}, 
      "Latitude"=>{"Searchable"=>false}, 
      "StreetDirPrefix"=>{"Searchable"=>false}, 
      "StreetAdditionalInfo"=>{"Searchable"=>false}, 
      "PropertyType"=>{"Searchable"=>true}, 
      "StateOrProvince"=>{"Searchable"=>true}, 
      "BathsTotal"=>{"Searchable"=>true}, 
      "BathsFull"=>{"Searchable"=>true}, 
      "ListingKey"=>{"Searchable"=>false}, 
      "StreetDirSuffix"=>{"Searchable"=>false}, 
      "BedsTotal"=>{"Searchable"=>true}, 
      "ModificationTimestamp"=>{"Searchable"=>false}, 
      "BathsHalf"=>{"Searchable"=>true}, 
      "CountyOrParish"=>{"Searchable"=>true}
    })
  end

  it "should respond to get" do
    StandardFields.should respond_to(:get)
  end
  

  after(:each) do 
    @stdfields = nil
  end

end
