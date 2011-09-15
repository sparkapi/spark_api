module FlexmlsApi
  module Models
    class Photo < Base
      extend Subresource
      self.element_name = "photos"
      
      EDITABLE_FIELDS = [:Picture, :FileName, :Name, :Caption, :Primary]
      
      def initialize(opts={})
        defaulted_opts = {}
        EDITABLE_FIELDS.each do |k|
          key = k.to_s()
          defaulted_opts[key] = opts[key] || nil
        end
        super(opts.merge(defaulted_opts))
      end

      def primary? 
        @attributes["Primary"] == true 
      end
      
      def save(arguments={})
        begin
          return save!(arguments)
        rescue NotFound, BadResourceRequest => e
          FlexmlsApi.logger.error("Failed to save resource #{self}: #{e.message}")
        end
        false
      end
      def save!(arguments={})
        payload = {"Photos" => [ build_photo_hash]}
        if exists?
          results = connection.put "#{self.class.path}/#{self.Id}", payload, arguments
        else
          results = connection.post self.class.path, payload, arguments
        end
        result = results.first
        load(result)
        true
      end
      
      def load_picture(file_name)
        self.Picture = Base64.encode64(File.open(file_name, 'rb').read).gsub(/\n/, '')
        self.FileName = File.basename(file_name)
      end
      
      def delete(args={})
        connection.delete("#{self.class.path}/#{self.Id}", args)
      end
      
      def exists?
        @attributes.include?("Id")
      end
      
      private
      
      def build_photo_hash
        results_hash = {} 
        EDITABLE_FIELDS.each do |k|
          key = k.to_s
          results_hash[key] = @attributes[key] unless @attributes[key].nil?
        end
        results_hash
      end

    end
  end
end
