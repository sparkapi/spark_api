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
          connection.delete("#{self.class.path}/#{self.Id}", arguments)
          @destroyed = true
          true
        end
        alias :delete :destroy # backwards compatibility

        def destroyed?; @destroyed ? @destroyed : false end

      end

    end
  end
end
