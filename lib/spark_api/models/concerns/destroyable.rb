module SparkApi
  module Models
    module Concerns

      module Destroyable

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def destroy(id, arguments = {})
            connection.delete("#{path}/#{id}", arguments)
          end

        end


        def destroy(arguments = {})
          self.errors = []
          begin
            return destroy!(arguments)
          rescue BadResourceRequest => e
            self.errors << {:code => e.code, :message => e.message}
            SparkApi.logger.error("Failed to destroy resource #{self}: #{e.message}")
          rescue NotFound => e
            SparkApi.logger.error("Failed to destroy resource #{self}: #{e.message}")
          end
          false
        end
        def destroy!(arguments = {})
          connection.delete(resource_uri, arguments) if persisted?
          @destroyed = true
          true
        end
        alias_method :delete, :destroy # backwards compatibility

        def destroyed?; @destroyed ? @destroyed : false end

      end

    end
  end
end
