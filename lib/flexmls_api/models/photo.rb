module FlexmlsApi
  module Models
    class Photo < Base
      extend Subresource
      self.element_name = "photos"
      attr_accessor :Picture, :Description, :Caption
      
      def initialize(opts={})
        super(opts)
        @Picture = opts["Picture"] || ""
        @Description = opts[":Description"] || ""
        @Caption = opts["Caption"] || ""
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
        payload = {"Photos" => [ {"Picture" => @Picture, "Caption"=> @Caption, "Description" => @Description}]}
        if @attributes.include?("Id")
          results = connection.put "#{self.class.path}/#{self.Id}", payload, arguments
        else
          results = connection.post self.class.path, payload, arguments
        end
        result = results.first
        load(result)
        true
      end
      
      def load_picture(file_name)
        self.Picture = ""
        @Picture = Base64.encode64(File.open(file_name, 'rb').read).gsub(/\n/, '')
      end
      
      def delete(args={})
        connection.delete("#{self.class.path}/#{self.Id}", args)
      end

    end
  end
end
