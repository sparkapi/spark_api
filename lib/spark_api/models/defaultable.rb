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
          find(DEFAULT_ID, options)
        end

        def find(*arguments)
          result = original_find(*arguments)
          if arguments.first == DEFAULT_ID
            result.Id = DEFAULT_ID if result.Id.nil?
          end
          result
        end

      end

    end
  end
end
