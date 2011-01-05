module FlexmlsApi
  module Models
    class Document < Base
      self.element_name="documents"
      
      def self.find_by_listing_key(key, api_user)
        docs = []
        resp = connection.get("/listings/#{key}#{self.path}", :ApiUser => api_user)
        resp.collect { |doc| docs.push(new(doc)) }
        docs
      end


    end
  end
end
