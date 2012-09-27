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
          attributes['Id'].nil? ? create!(arguments) : update!(arguments)
        end

        def create!(arguments = {})
          resources = self.class.name.demodulize.pluralize
          results = connection.post self.class.path, { resources => [ attributes ] }, arguments
          result = results.first
          attributes['ResourceUri'] = result['ResourceUri']
          attributes['Id'] = parse_id(result['ResourceUri'])
          true
        end

        def update!(arguments= {})
          connection.put "#{self.class.path}/#{self.Id}", changed_attributes, arguments
          self.changed = []
          true
        end

      end

    end
  end
end
