module SparkApi
  module Models
    module Concerns

      module Destroyable

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
          if persisted?
            request_path = self.singular? ? self.path : "#{self.path}/#{self.Id}"
            connection.delete(request_path, arguments) if persisted?
          end
          @destroyed = true
          true
        end
        alias_method :delete, :destroy # backwards compatibility

        def destroyed?; @destroyed ? @destroyed : false end

      end

    end
  end
end
