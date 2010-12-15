module FlexmlsApi
  class Listing 
    attr_accessor :attributes


    def initialize(attributes={})
      puts (attributes.inspect)
      @attributes = {}
      load(attributes)
    end



    #self.base = '/listings'

    class << self
      def find(*arguments)
        scope = arguments.slice!(0)
        options = arguments.slice!(0) || {}
        
        case scope
          when :all   then find_every(options)
          when :first then find_every(options).first
          when :last  then find_every(options).last
          when :one   then find_one(options)
          else             find_single(scope, options)
        end
      end
      
      def first(*arguments)
        find(:first, *arguments)
      end

      def last(*arguments)
        find(:last, *arguments)
      end


      private

        def find_every(options)
          raise NotImplementedError # TODO
        end

        def find_one(options)
          raise NotImplementedError # TODO
        end

        def find_single(scope,options)
          puts "Scope: #{scope}\nOptions: #{options}"
          puts "endpoint: #{FlexmlsApi.client.endpoint}"
          # resp = FlexmlsApi.client.get ("/listings/#{scope}", options)
          # resp[0]
          # new(resp)
          new({"ResourceUri"=>"/vX/listings/20060412165917817933000000", "StandardFields"=>{"StreetNumber"=>"611", "Longitude"=>"-96.792246", "City"=>"Fargo", "ListingId"=>"10-1796", "PublicRemarks"=>"Great foyer. Cool kitchen. 6 fireplaces. The list goes on.", "BuildingAreaTotal"=>"7275.0", "YearBuilt"=>1884, "StreetName"=>"8th", "PostalCode"=>"58103", "ListPrice"=>"1079900.0", "Latitude"=>"46.868464", "BathsThreeQuarter"=>1, "foo"=>"bar", "BathsFull"=>5, "BathsTotal"=>"8.0", "StateOrProvince"=>"ND", "StreetAdditionalInfo"=>nil, "StreetDirPrefix"=>nil, "PropertyType"=>"A ", "BedsTotal"=>8, "StreetDirSuffix"=>"S", "ListingKey"=>"20060412165917817933000000", "ModificationTimestamp"=>"2010-11-22T20:09:37Z", "BathsHalf"=>2, "CountyOrParish"=>nil}, "Id"=>"20060412165917817933000000"})
        end


    end # /class 

    def load(attributes)
      attributes.each do |key,val|
        @attributes[key.to_s] = val
      end
    end


    def method_missing(method_symbol, *arguments)
      method_name = method_symbol.to_s

      return @attributes[method_name] if attributes.include?(method_name)
      return @attributes['StandardFields'][method_name] if attributes['StandardFields'].include?(method_name)
      super
    end
  end
end
