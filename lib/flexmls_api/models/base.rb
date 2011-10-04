module FlexmlsApi
  module Models
    # =API Model Base class
    # Intended to be a lot like working with ActiveResource, this class adds most of the basic 
    # active model type niceties.
    class Base
      extend Paginate

      attr_accessor :attributes
      attr_reader :changed
      
      # Name of the resource as related to the path name
      def self.element_name
        # TODO I'd love to pull in active model at this point to provide default naming
        @element_name ||= "resource"
      end

      def self.element_name=(name)
        @element_name = name
      end
      
      # Resource path prefix, prepended to the url
      def self.prefix
        @prefix ||= "/"
      end
      def self.prefix=(prefix)
        @prefix = prefix
      end
      def self.path
        "#{prefix}#{element_name}"
      end
      
      def self.connection
        FlexmlsApi.client
      end
      def connection
        self.class.connection
      end

      def initialize(attributes={})
        @attributes = {}
        @changed = []
        load(attributes)
      end

      def load(attributes)
        attributes.each do |key,val|
          @attributes[key.to_s] = val
        end
      end
      
      def self.get(options={})
        collect(connection.get(path, options))
      end

      def self.first(options={})
        get(options).first
      end

      def self.count(options={})
        connection.get(path, options.merge({:_pagination=>"count"}))
      end
      
      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s

        if method_name =~ /(=|\?)$/
          case $1
          when "=" 
            write_attribute($`, arguments.first)
            # TODO figure out a nice way to present setters for the standard fields
          when "?" 
            if attributes.include?($`)
              attributes[$`] ? true : false
            else
              raise NoMethodError
            end
          end 
        else
          return attributes[method_name] if attributes.include?(method_name)
          super # GTFO
        end
      end
      
      def respond_to?(method_symbol, include_private=false)
        if super
          return true
        else
          method_name = method_symbol.to_s

          if method_name =~ /=$/
            true
          elsif method_name =~ /(\?)$/
            attributes.include?($`)
          else
            attributes.include?(method_name)
          end

        end
      end
      
      def parse_id(uri)
        uri[/\/.*\/(.+)$/, 1]
      end
      
      protected
      
      def write_attribute(attribute,  value)
        unless attributes[attribute] == value
          attributes[attribute] = value
          @changed << attribute unless @changed.include?(attribute)
        end
      end
        
    end
  end
end
