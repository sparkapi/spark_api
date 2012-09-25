module SparkApi

  module Saveable
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
    def create!; raise "To be implemented by modifier" end
    def update!; raise "To be implemented by modifier" end
  end

  module Createable
    include Saveable
    def create!(arguments = {})
      resources = self.class.name.demodulize.pluralize
      results = connection.post self.class.path, { resources => [ attributes ] }, arguments
      result = results.first
      attributes['ResourceUri'] = result['ResourceUri']
      attributes['Id'] = parse_id(result['ResourceUri'])
      true
    end
  end

  module Updateable
    include Saveable
    def update!(arguments= {})
      connection.put "#{self.class.path}/#{self.Id}", changed_attributes, arguments
      @changed = []
    end
  end

  module Destroyable
    def delete(arguments = {})
      connection.delete("#{self.class.path}/#{self.Id}", arguments)
    end
  end

end
