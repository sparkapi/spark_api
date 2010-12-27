module FlexmlsApi
  module Models
    class IdxLink < Model

      def self.get
        instances = []
        resp = FlexmlsApi.client.get('/idxlinks')
        resp.each do |p|
          instances.push(new(p))
        end
        instances
      end
      
      
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

      private

      def self.find_every(options)
        raise NotImplementedError # TODO
      end

      def self.find_one(options)
        raise NotImplementedError # TODO
      end

      def self.find_single(scope, options)
        resp = FlexmlsApi.client.get("/idxlinks/#{scope}", options)
        new(resp[0])
      end

    end
  end
end
