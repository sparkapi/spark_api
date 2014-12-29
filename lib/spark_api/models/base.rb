module SparkApi
  module Models
    # =API Model Base class
    # Intended to be a lot like working with ActiveResource, this class adds most of the basic 
    # active model type niceties.
    class Base
      extend Paginate
      include Dirty

      attr_accessor :attributes, :errors, :parent

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

      def resource_uri
        self.ResourceUri.sub(/^\/#{SparkApi.client.version}/, "") if persisted?
      end

      def self.path
        "#{prefix}#{element_name}"
      end
      def path
        if self.persisted?
          resource_uri.sub(/\/[0-9]{26}$/, "")
        else
          if @parent
            "#{@parent.class.path}/#{@parent.Id}#{self.class.path}"
          else
            self.class.path
          end
        end
      end

      def self.connection
        SparkApi.client
      end
      def connection
        self.class.connection
      end

      def initialize(attributes={})
        @attributes = {}
        @errors = []
        load(attributes, { :clean => true })
      end

      def load(attributes, options = {})
        attributes.each do |key,val|
          attribute_will_change!(key) unless options[:clean]
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

        if method_name =~ /(=|\?|_will_change!)$/
          case $1
          when "=" 
            write_attribute($`, arguments.first)
            # TODO figure out a nice way to present setters for the standard fields
          when "?" 
            raise NoMethodError unless attributes.include?($`)
            attributes[$`] ? true : false
          when "_will_change!"
            raise NoMethodError unless attributes.include?($`)
            attribute_will_change!($`)
          end 
        else
          return attributes[method_name] if attributes.include?(method_name)
          super # GTFO
        end
      end

      def respond_to?(method_symbol, include_all=false)
        if super
          return true
        else
          method_name = method_symbol.to_s

          if method_name =~ /=$/
            true
          elsif method_name =~ /(\?)$/
            attributes.include?($`)
          elsif method_name =~ /(\w*)_will_change!$/
            attributes.include?($1)
          else
            attributes.include?(method_name)
          end

        end
      end

      def parse_id(uri)
        uri[/\/.*\/(.+)$/, 1]
      end

      def persisted?;
        !@attributes['Id'].nil? && !@attributes['ResourceUri'].nil?
      end

      def to_param
        attributes['Id']
      end

      protected

      def write_attribute(attribute, value)
        attribute = attribute.to_s
        unless attributes[attribute] == value
          attribute_will_change!(attribute)
          attributes[attribute] = value
        end
      end

    end
  end
end
