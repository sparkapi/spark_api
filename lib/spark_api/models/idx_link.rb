module SparkApi
  module Models
    class IdxLink < Base
      self.element_name="idxlinks"
      
      LINK_TYPES = ["QuickSearch", "SavedSearch", "MyListings", "Roster"]

      #TODO Work all below into common base class
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

      def self.default(options = {})
        response = connection.get("/#{self.element_name}/default", options).first
        response.nil? ? nil : new(response)
      end

      private

      def self.find_every(options)
        raise NotImplementedError # TODO
      end

      def self.find_one(options)
        raise NotImplementedError # TODO
      end

      def self.find_single(scope, options)
        resp = SparkApi.client.get("/idxlinks/#{scope}", options)
        new(resp.first)
      end

    end
  end
end
