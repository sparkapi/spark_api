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

        def find_single(scope, options)
          resp = FlexmlsApi.client.get("/listings/#{scope}", options)
          new(resp)
        end


    end # /class 

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
        return @attributes['StandardFields'][method_name] if attributes['StandardFields'].include?(method_name)
        super # GTFO
      end
    end
  end
end
