module SparkApi
  module Models
    module Defaultable

      DEFAULT_ID = "default"

      extend Finders

      def self.included(base)

        class << base
          alias original_find find
        end

        base.extend(ClassMethods)

      end
  
      module ClassMethods

        def default(options = {})
          response = connection.get("/#{element_name}/default", options).first
          unless response.nil?
            response["Id"] = DEFAULT_ID if response["Id"].nil?
            new(response)
          end
        end

        def find(*arguments)
          if arguments.first == DEFAULT_ID
            default
          else
            original_find(*arguments)
          end
        end

      end

    end
  end
end
