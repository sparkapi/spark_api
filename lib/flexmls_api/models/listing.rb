module FlexmlsApi
  module Models
    class Listing < Base 
      extend Finders
      attr_accessor :photos, :videos, :virtual_tours, :documents
      self.element_name="listings"

      def initialize(attributes={})
        @photos = []
        @videos = []
        @virtual_tours = []
        @documents = []

          
        if attributes.has_key?('StandardFields')
          pics, vids, tours, docs = attributes['StandardFields'].values_at('Photos','Videos', 'VirtualTours', 'Documents')
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
      
      def tour_of_homes(arguments={})
        return @tour_of_homes unless @tour_of_homes.nil?
        @tour_of_homes = TourOfHome.find_by_listing_key(self.Id, arguments)
      end

      def open_houses(arguments={})
        return @open_houses unless @open_houses.nil?
        @open_houses = OpenHouse.find_by_listing_key(self.Id, arguments)
      end
      
      def my_notes
        Note.build_subclass.tap do |note|
          note.prefix = "/listings/#{self.ListingKey}"
          note.element_name = "/my/notes"
          FlexmlsApi.logger.info("Note.path: #{note.path}")
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

      
      private

      # TODO trim this down so we're only overriding the StandardFields access
      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s

        if method_name =~ /(=|\?)$/
          case $1
          when "="
            attributes[$`] = arguments.first
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
    end
  end
end
