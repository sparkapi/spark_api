module SparkApi
    module Models
      module Media
        # This module is effectively an interface and helper to combine common media
        # actions and information. Media types (videos, virtual tours, etc)
        # should include this module and implement the methods contained

        def url
            raise "Not Implemented"
        end

        def description
            raise "Not Implemented"
        end

        def private?
            attributes['Privacy'] == 'Private'
        end
          
        def public?
            attributes['Privacy'] == 'Public'
        end
          
        def automatic?
            attributes['Privacy'] == 'Automatic'
        end

      end
    end
end
