module FlexmlsApi
  module Models
    class StandardFields < Base
      extend Finders
      self.element_name="standardfields"
      
      # expand all fields passed in
      def self.find_and_expand_all(fields, arguments={})
        returns = {}
        
        # find all standard fields, but expand only the location fields
        # TODO: when _expand support is added to StandardFields API, use the following
        # standard_fields = find(:all, :ApiUser => owner, :_expand => fields.join(",")) 
        standard_fields = find(:all, arguments) 
      
        # filter through the list and return only the location fields found
        fields.each do |field|
          # search for field in the payload
          if standard_fields.first.attributes.has_key?(field)
            returns[field] = standard_fields.first.attributes[field]
              
            # lookup fully _expand fileld, if the field has a list
            if returns[field]['HasList']
              returns[field] = connection.get("/standardfields/#{field}", arguments).first[field]
            end
              
          end
        end
        
        returns
      end
      
    end
  end
end
