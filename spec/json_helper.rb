
class ListingJson
  @counter = 0
  def self.next_tech_id()
    "#{@counter + 20110101000000000000}000000"
  end
  def self.next_list_id()
    "06-#{@counter + 1000}"
  end
  def self.bump()
    @counter += 1
  end
  
  def self.create
    bump
    json = <<-JSON 
      {
        "ResourceUri": "/v1/listings/#{next_tech_id}",
        "StandardFields": #{standard_fields},
        "Id": "#{next_tech_id}"
      }
    JSON
     
  end
  
  def self.create_all(count = 1)
    listings = []
    count.times { listings << create }
    json = listings * ","
  end
  
  private
  def self.standard_fields
    json = <<-JSON 
        {
          "StreetNumber": "7298",
          "Longitude": "-116.3237",
          "City": "Bonners Ferry",
          "ListingId": "#{next_list_id}",
          "PublicRemarks": "Afforadable home in town close to hospital,yet quiet country like setting. Good views. Must see",
          "BuildingAreaTotal": 924.0,
          "YearBuilt": 1977,
          "StreetName": "BIRCH",
          "ListPrice": 50000.0,
          "PostalCode": 83805,
          "Latitude": "48.7001",
          "BathsThreeQuarter": null,
          "BathsFull": 1.0,
          "BathsTotal": 1.0,
          "StateOrProvince": "ID",
          "PropertyType": "A",
          "StreetAdditionalInfo": null,
          "StreetDirPrefix": null,
          "BedsTotal": 3,
          "StreetDirSuffix": null,
          "ListingKey": "#{next_tech_id}",
          "ListOfficeName": "Century 21 On The Lake",
          "BathsHalf": null,
          "ModificationTimestamp": "2010-11-22T20:47:21Z",
          "CountyOrParish": "Boundary"        
        }
    JSON
  end

end

def paginate_json(current_page = 1)
  json = <<-JSON 
    "Pagination": {
      "TotalRows": 38,
      "PageSize": 10,
      "TotalPages": 4,
      "CurrentPage": #{current_page}
    }
  JSON
end

