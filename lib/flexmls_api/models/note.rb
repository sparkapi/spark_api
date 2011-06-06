module FlexmlsApi
  module Models
    class Note < Base
      extend Subresource 
      self.element_name = "notes" # not sure this is really of any use...
      
      def self.get(options={})
        ret = super(options)
        if ret.empty?
          return nil
        else
          return ret.first
        end
      end

      def save(arguments={})
        begin
          return save!(arguments)
        rescue BadResourceRequest => e
        rescue NotFound => e
          # log and leave
          FlexmlsApi.logger.error("Failed to save note #{self} (path: #{self.class.path}): #{e.message}")
        end 
        false
      end 

      def save!(args={})
        args.merge(:Notes => attributes['Note'])
        results = connection.put(self.class.path, {:Note => attributes['Note']}, args)
        result = results.first
        attributes['ResourceUri'] = result['ResourceUri']
        true
      end 

      def delete(args={})
        connection.delete(self.class.path, args)
      end

    end
  end
end
