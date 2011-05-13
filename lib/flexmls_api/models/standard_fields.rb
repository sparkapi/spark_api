module FlexmlsApi
  module Models
    class StandardFields < Base
      extend Finders
      self.element_name="standardfields"
      
      # expand all fields passed in
      def self.find_and_expand_all(fields, arguments={}, max_list_size=1000)
        returns = {}
        
        # find all standard fields, but expand only the location fields
        # TODO: when _expand support is added to StandardFields API, use the following
        # standard_fields = find(:all, {:ApiUser => owner, :_expand => fields.join(",")}) 
        standard_fields = find(:all, arguments)
      
        # filter through the list and return only the location fields found
        fields.each do |field|
          # search for field in the payload
          if standard_fields.first.attributes.has_key?(field)
            returns[field] = standard_fields.first.attributes[field]
              
            # lookup fully _expand field, if the field has a list
            if returns[field]['HasList'] && returns[field]['MaxListSize'].to_i <= max_list_size
              returns[field] = connection.get("/standardfields/#{field}", arguments).first[field]
            end
              
          end
        end
        
        returns
      end
      
      
      # find_nearby: find fields nearby via lat/lon
      def self.find_nearby(prop_types = ["A"], arguments={})
        return_json = {"D" => {"Success" => true, "Results" => []} }
        
        # add _expand=1 so the fields are returned
        arguments.merge!({:_expand => 1})
        
        # find and return
        return_json["D"]["Results"] = connection.get("/standardfields/nearby/#{prop_types.join(',')}", arguments)
        
        # return
        return_json
      end
      
    end
  end
end
