module SparkApi
  module Models
    class Listing < Base
      extend Finders
      attr_accessor :photos, :videos, :virtual_tours, :documents, :open_houses, :tour_of_homes, :rental_calendars
      attr_accessor :constraints
      self.element_name='listings'
      DATA_MASK        = '********'
      WRITEABLE_FIELDS = %w(ListPrice ExpirationDate)

      STANDARD_FIELDS_KEY = 'StandardFields'
      RENTAL_CALENDAR_KEY = 'RentalCalendar'
      PHOTOS_KEY          = 'Photos'
      VIDEOS_KEY          = 'Videos'
      VIRTUAL_TOURS_KEY   = 'VirtualTours'
      DOCUMENTS_KEY       = 'Documents'
      OPEN_HOUSES_KEY     = 'OpenHouses'
      TOUR_OF_HOMES_KEY   = 'TourOfHomes'

      PERMISSIONS_KEY                  = 'Permissions'
      EDITABLE_PERMISSIONS_KEY         = 'Editable'
      EDITABLE_SETTINGS_PERMISSION_KEY = 'EditableSettings'
      EXPIRATION_DATE_KEY              = 'ExpirationDate'

      STREET_ADDRESS_SEPARATOR = ' '
      BLANK_STR = ''

      def initialize(attributes={})
        @photos = []
        @videos = []
        @virtual_tours = []
        @rental_calendars = []
        @documents = []
        @constraints = []
        @tour_of_homes = []
        @open_houses = []

        standard_fields = attributes[STANDARD_FIELDS_KEY]

        if standard_fields
          pics, vids, tours, docs, ohouses, tourhomes = standard_fields.values_at(
              PHOTOS_KEY, VIDEOS_KEY, VIRTUAL_TOURS_KEY, DOCUMENTS_KEY, OPEN_HOUSES_KEY, TOUR_OF_HOMES_KEY
          )
        end

        if attributes.has_key?(RENTAL_CALENDAR_KEY)
          rentalcalendars = attributes[RENTAL_CALENDAR_KEY]
        end

        if pics != nil
          setup_attribute(@photos, pics, Photo)
          standard_fields.delete(PHOTOS_KEY)
        end

        if vids != nil
          setup_attribute(@videos, vids, Video)
          standard_fields.delete(VIDEOS_KEY)
        end

        if tours != nil
          setup_attribute(@virtual_tours, tours, VirtualTour)
          standard_fields.delete(VIRTUAL_TOURS_KEY)
        end

        if docs != nil
          setup_attribute(@documents, docs, Document)
          standard_fields.delete(DOCUMENTS_KEY)
        end

        if ohouses != nil
          setup_attribute(@open_houses, ohouses, OpenHouse)
          standard_fields.delete(OPEN_HOUSES_KEY)
        end

        if tourhomes != nil
          setup_attribute(@tour_of_homes, tourhomes, TourOfHome)
          standard_fields.delete(TOUR_OF_HOMES_KEY)
        end

        if rentalcalendars != nil
          setup_attribute(@rental_calendars, rentalcalendars, RentalCalendar)
          attributes.delete(RENTAL_CALENDAR_KEY)
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

      def self.tour_of_homes(arguments={})
        collect(connection.get("/listings/tourofhomes", arguments))
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
        street_address_entries = [
          self.StreetNumber, self.StreetDirPrefix, self.StreetName, self.StreetSuffix,
          self.StreetDirSuffix, self.StreetAdditionalInfo
        ] - [DATA_MASK, BLANK_STR]
        street_address = street_address_entries.join(STREET_ADDRESS_SEPARATOR)
        street_address.strip().gsub(/\s{2,}/, STREET_ADDRESS_SEPARATOR)
      end

      def region_address
        "#{self.City}, #{self.StateOrProvince} #{self.PostalCode}".
          delete(DATA_MASK).strip().gsub(/^,\s/, BLANK_STR).gsub(/,$/, BLANK_STR)
      end

      def full_address
        "#{self.street_address}, #{self.region_address}".
          strip().gsub(/^,\s/, BLANK_STR).gsub(/,$/, BLANK_STR)
      end

      def save(arguments={})
        self.errors = []
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
          self.errors << {:code => e.code, :message => e.message}
          if e.code == 1053
            @constraints = []
            e.details.each do |detail|
              detail.each_pair do |k,v|
                v.each { |constraint| @constraints << Constraint.new(constraint)}
              end
            end
          end
          SparkApi.logger.warn { "Failed to save resource #{self}: #{e.message}" }
        rescue NotFound => e
          SparkApi.logger.error { "Failed to save resource #{self}: #{e.message}" }
        end
        false
      end

      def save!(arguments={})
        writable_changed_keys = changed & WRITEABLE_FIELDS
        if writable_changed_keys.empty?
          SparkApi.logger.warn { "No supported listing change detected" }
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

      def reorder_photos(arguments={})
        begin
          return reorder_photos!(arguments)
        rescue BadResourceRequest => e
          SparkApi.logger.warn { "Failed to save resource #{self}: #{e.message}" }
        rescue NotFound => e
          SparkApi.logger.error { "Failed to save resource #{self}: #{e.message}" }
        end
        false
      end
      def reorder_photos!(arguments={})
        connection.put "#{self.class.path}/#{self.Id}/photos", arguments
        true
      end

      def editable?(editable_settings = [])
        editable = attributes.include?(PERMISSIONS_KEY) &&
          self.Permissions[EDITABLE_PERMISSIONS_KEY] == true

        editable && Array(editable_settings).all? do |setting|
          self.Permissions[EDITABLE_SETTINGS_PERMISSION_KEY][setting.to_s] == true
        end
      end

      def ExpirationDate
        attributes[EXPIRATION_DATE_KEY]
      end

      def ExpirationDate=(value)
        write_attribute(EXPIRATION_DATE_KEY, value)
      end

      def respond_to?(method_symbol, include_all=false)
        if super
          true
        else
          standard_fields.include?(method_symbol.to_s) rescue false
        end
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
          return standard_fields[method_name] if standard_fields.include?(method_name)
          super # GTFO
        end
      end

      def standard_fields
        @standard_fields ||= attributes[STANDARD_FIELDS_KEY]
      end

      def build_hash(keys)
        hash = {}
        keys.each do |key|
          hash[key] = attributes[key]
        end
        hash
      end

      # Determine if passed a model or hash and push instance of Klass onto attributes array
      def setup_attribute(attributes, collection, klass)
        collection.collect do |c|
          attribute = (c.instance_of? klass) ? c : klass.new(c)
          attributes.push(attribute)
        end
      end

    end
  end
end
