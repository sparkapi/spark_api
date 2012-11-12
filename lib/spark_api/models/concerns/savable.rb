module SparkApi
  module Models
    module Concerns

      module Savable

        def save(arguments = {})
          self.errors = [] # clear the errors hash
          begin
            return save!(arguments)
          rescue BadResourceRequest => e
            self.errors << {:code => e.code, :message => e.message}
            SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
            SparkApi.logger.error(e.inspect)
          rescue NotFound => e
            SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
          end
          false
        end
        def save!(arguments = {})
          save_results =  persisted? ? update!(arguments) : create!(arguments)
          assoc_save_results = true
          assoc_save_results = save_associated_resources! if associations_changed?
          save_results && assoc_save_results
        end

        def create!(arguments = {})
          save_path = self.singular? ? self.save_path : self.class.path
          results = connection.post save_path, post_data.merge(params_for_save), arguments
          update_resource_identifiers(results.first)
          reset_dirty
          params_for_save.clear
          true
        end

        def update!(arguments = {})
          return true unless changed?
          save_path = self.singular? ? self.save_path : "#{self.class.path}/#{self.Id}"
          connection.put save_path, dirty_attributes, arguments
          reset_dirty
          params_for_save.clear
          true
        end

        def save_associated_resources!
          new_resources = {}
          persisted_resources = []
          changed_associated_objects.each do |ao|
            if ao.persisted?
              persisted_resources << ao
            else
              new_resources[ao.class] = [] if new_resources[ao.class].nil?
              new_resources[ao.class] << ao
            end
          end

          # Group the new resources by type and create them
          new_resources.each do |resource_class, resources_to_create|
             create_associated_resources! resource_class,  resources_to_create
          end

          # Save the changes to each of the already persisted resources
          persisted_resources.each{ |pr| pr.save }

          # Set the association's array to nil so that it fetches fresh data when it's called again
          reset_changed_associations

          true
        end

        # Create the new resources in one POST request
        def create_associated_resources!(resource_class, resources_to_create, arguments = {})
          post_path = "#{self.class.path}/#{self.Id}/#{resource_class.element_name}"
          resources_attributes = resources_to_create.collect{|res_obj| res_obj.attributes}
          pluralized_class_name = resources_to_create.first.send :resource_pluralized
          results = connection.post post_path, { pluralized_class_name => resources_attributes }, arguments
          true
        end

        def params_for_save
          @params_for_save ||= {}
        end

        # can be overridden
        def post_data
          { resource_pluralized => [ attributes ] }
        end

        private 

        def update_resource_identifiers(result)
          attributes['ResourceUri'] = result['ResourceUri']
          attributes['Id'] = result['Id'] ? result['Id'] : parse_id(result['ResourceUri'])
        end

        # can be overridden
        def resource_pluralized
          resource = self.class.name.split('::').last
          unless resource.split('').last == "s"
            resource = resource + "s"
          end
          resource
        end

      end

    end
  end
end
