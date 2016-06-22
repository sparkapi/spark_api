module SparkApi
  module Models
    # =Rails-like finders module
    # Adds the base set of finder class methods to the models that support them (not all of them do) 
    module Finders

      def find(*arguments)
        scope = arguments.slice!(0)
        options = arguments.slice!(0) || {}
        case scope
          when nil    then raise ArgumentError, "Argument for find() can't be nil"
          when :all   then find_every(options)
          when :first then find_every(options).first
          when :last  then find_every(options).last
          when :one   then find_every(options.merge(:_limit => 1)).first
          else             find_single(scope, options)
        end
      end

      def find_one(*arguments)
        find(:one, *arguments)
      end
      
      def first(*arguments)
        find(:first, *arguments)
      end
      
      def last(*arguments)
        find(:last, *arguments)
      end
      
      private

      def find_every(options)
        collect(connection.get("#{path}", options))
      end

      def find_single(scope, options)
        resp = connection.get("#{path}/#{scope}", options)
        unless resp.first.nil?
          new(resp.first)
        end
      end
            
    end
  end
end
    
