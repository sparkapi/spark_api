module FlexmlsApi
  module Models
    class Listing < Model 
      attr_accessor :photos

      def initialize(attributes={})
        @photos = []
        if (attributes.has_key?('StandardFields') and attributes['StandardFields'].has_key?('Photos'))
          attributes['StandardFields']['Photos'].collect do |photo|
            @photos.push(Photo.new(photo))
          end
          attributes['StandardFields'].delete('Photos')
        end
      
        super(attributes)
      end


      def self.find(*arguments)
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
      
      def self.first(*arguments)
        find(:first, *arguments)
      end

      def self.last(*arguments)
        find(:last, *arguments)
      end

      def self.my(arguments={})
        my_listings = []
        response = FlexmlsApi.client.get("/my/listings", arguments)
        response.collect { |listing| my_listings.push(new(listing)) }
        my_listings
      end


      private

      def self.find_every(options)
        raise NotImplementedError # TODO
      end

      def self.find_one(options)
        raise NotImplementedError # TODO
      end

      def self.find_single(scope, options)
        resp = FlexmlsApi.client.get("/listings/#{scope}", options)
        new(resp[0])
      end


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
