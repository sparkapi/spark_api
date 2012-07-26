module SparkApi
  module Models
    class Listing < Base 
      extend Finders
      attr_accessor :photos, :videos, :virtual_tours, :documents, :open_houses, :tour_of_homes, :rental_calendars
      attr_accessor :constraints
      self.element_name="listings"
      DATA_MASK = "********"
      WRITEABLE_FIELDS = ["ListPrice", "ExpirationDate"]

      def initialize(attributes={})
        @photos = []
        @videos = []
        @virtual_tours = []
        @rental_calendars = []
        @documents = []
        @constraints = []
        #@tour_of_homes = []
        
        if attributes.has_key?('StandardFields')
          pics, vids, tours, docs, ohouses, tourhomes = attributes['StandardFields'].values_at('Photos','Videos', 'VirtualTours', 'Documents', 'OpenHouses', 'TourOfHomes')
        end
        
        if attributes.has_key?('RentalCalendar')
          rentalcalendars = attributes['RentalCalendar']
        end
        
        if pics != nil
          pics.collect { |pic| @photos.push(Photo.new(pic)) } 
          attributes['StandardFields'].delete('Photos')
        end
        
        if vids != nil
          vids.collect { |vid| @videos.push(Video.new(vid)) } 
          attributes['StandardFields'].delete('Videos')
        end

        if tours != nil
          tours.collect { |tour| @virtual_tours.push(VirtualTour.new(tour)) }
          attributes['StandardFields'].delete('VirtualTours')
        end

        if docs != nil
          docs.collect { |doc| @documents.push(Document.new(doc)) }
          attributes['StandardFields'].delete('Documents')
        end
        
        if ohouses != nil
          @open_houses = []
          ohouses.collect { |ohouse| @open_houses.push(OpenHouse.new(ohouse)) }
          attributes['StandardFields'].delete('OpenHouses')
        end
        
        if tourhomes != nil
          @tour_of_homes = []
          tourhomes.collect { |tourhome| @tour_of_homes.push(TourOfHome.new(tourhome)) }
          attributes['StandardFields'].delete('TourOfHomes')
        end
        
        if rentalcalendars != nil
          rentalcalendars.collect { |rentalcalendar| @rental_calendars.push(RentalCalendar.new(rentalcalendar)) }
          attributes.delete('RentalCalendar')
        end        
        
        super(attributes)
      end

      def self.find_by_cart_id(cart_id, options={}) 
        query = {:_filter => "ListingCart Eq '#{cart_id}'"}
        find(:all, options.merge(query)) 
      end
      
      def self.my(arguments={})
        collect(connection.get("/my/listings", arguments))
      end

      def self.office(arguments={})
        collect(connection.get("/office/listings", arguments))
      end

      def self.company(arguments={})
        collect(connection.get("/company/listings", arguments))
      end
      
      def self.nearby(latitude, longitude, arguments={})
        nearby_args = {:_lat => latitude, :_lon => longitude}.merge(arguments)
        collect(connection.get("/listings/nearby", nearby_args))
      end
      
      def tour_of_homes(arguments={})
        @tour_of_homes ||= TourOfHome.find_by_listing_key(self.Id, arguments)
        return @tour_of_homes unless @tour_of_homes.nil?
      end

      def rental_calendars(arguments={})
        @rental_calendars ||= RentalCalendar.find_by_listing_key(self.Id, arguments)
        return @rental_calendars unless @rental_calendars.nil?
      end


      def open_houses(arguments={})
        @open_houses ||= OpenHouse.find_by_listing_key(self.Id, arguments)
        return @open_houses unless @open_houses.nil?
      end
      
      def my_notes
        Note.build_subclass.tap do |note|
          note.prefix = "/listings/#{self.ListingKey}"
          note.element_name = "/my/notes"
          SparkApi.logger.info("Note.path: #{note.path}")
        end
      end

      # 'fore' is required when accessing an agent's shared
      # notes for a specific contact. If the ApiUser /is/ the
      # contact, then it can be inferred by the api, so it's
      # unecessary
      def shared_notes(fore=nil)
        Note.build_subclass.tap do |note|
          note.prefix = "/listings/#{self.ListingKey}"
          if fore.nil?
            note.element_name = "/shared/notes"
          else
            note.element_name = "/shared/notes/contacts/#{fore}"
          end
        end
      end

      def street_address
        "#{self.StreetNumber} #{self.StreetDirPrefix} #{self.StreetName} #{self.StreetSuffix} #{self.StreetDirSuffix} #{self.StreetAdditionalInfo}".delete(DATA_MASK).strip().gsub(/\s{2,}/, ' ')
      end

      def region_address
        "#{self.City}, #{self.StateOrProvince} #{self.PostalCode}".delete(DATA_MASK).strip().gsub(/^,\s/, '').gsub(/,$/, '')
      end

      def full_address
        "#{self.street_address}, #{self.region_address}".strip().gsub(/^,\s/, '').gsub(/,$/, '')
      end
      
      def save(arguments={})
        self.errors = []
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
          self.errors << {:code => e.code, :message => e.message}
          SparkApi.logger.debug("BHDEBUG: #{e.inspect}")
          if e.code == 1053
            @constraints = []
            e.details.each do |detail|
              detail.each_pair do |k,v|
                v.each { |constraint| @constraints << Constraint.new(constraint)}
              end
            end
          end
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        rescue NotFound => e
          SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        writable_changed_keys = changed & WRITEABLE_FIELDS
        if writable_changed_keys.empty?
          SparkApi.logger.warn("No supported listing change detected")
        else
          results = connection.put "#{self.class.path}/#{self.Id}", build_hash(writable_changed_keys), arguments
          @contstraints = []
          results.details.each do |detail|
            detail.each_pair do |k,v|
              v.each { |constraint| @constraints << Constraint.new(constraint)}
            end
          end
        end
        true
      end
      
      def editable?(editable_settings = [])
        settings = Array(editable_settings)
        editable = attributes.include?("Permissions") && self.Permissions["Editable"] == true
        if editable
          settings.each{ |setting| editable = false unless self.Permissions["EditableSettings"][setting.to_s] == true }
        end
        editable
      end
      
      def ExpirationDate
        attributes["ExpirationDate"]
      end
      def ExpirationDate=(value)
        write_attribute("ExpirationDate", value)
      end
      
      
      private

      # TODO trim this down so we're only overriding the StandardFields access
      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s

        if method_name =~ /(=|\?)$/
          case $1
          when "="
            write_attribute($`,arguments.first)
            # TODO figure out a nice way to present setters for the standard fields
          when "?"
            attributes[$`]
          end  
        else 
          return attributes[method_name] if attributes.include?(method_name)
          return @attributes['StandardFields'][method_name] if attributes['StandardFields'].include?(method_name)
          super # GTFO
        end
      end
      
      def build_hash(keys)
        hash = {}
        keys.each do |key|
          hash[key] = attributes[key]
        end
        hash
      end
      
    end
  end
end
