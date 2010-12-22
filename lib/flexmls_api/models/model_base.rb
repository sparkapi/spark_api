module FlexmlsApi
  module Models
    class Model

      attr_accessor :attributes

      def initialize(attributes={})
        @attributes = {}
        load(attributes)
      end

      def load(attributes)
        attributes.each do |key,val|
          @attributes[key.to_s] = val
        end
      end

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
          super # GTFO
        end 
      end
    end
  end
end
