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
          rescue NotFound => e
            SparkApi.logger.error("Failed to save resource #{self}: #{e.message}")
          end
          false
        end
        def save!(arguments = {})
          persisted? ? update!(arguments) : create!(arguments)
        end

        def create!(arguments = {})
          results = connection.post self.class.path, {
            resource_pluralized => [ attributes ]
          }.merge(params_for_save), arguments

          update_resource_identifiers(results.first)
          reset_dirty
          params_for_save.clear
          true
        end

        def update!(arguments = {})
          return true unless changed?
          connection.put "#{self.class.path}/#{self.Id}", dirty_attributes, arguments
          reset_dirty
          params_for_save.clear
          true
        end

        def params_for_save
          @params_for_save ||= {}
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
