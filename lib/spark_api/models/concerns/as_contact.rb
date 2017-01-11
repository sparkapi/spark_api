module SparkApi
  module Models
    module Concerns
      module AsContact

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          
          def as_contact(contact)
            id = contact.is_a?(Contact) ? contact.Id : contact
            modified = dup
            modified.prefix = "/contacts/#{id}/"
            @@klass = self

            modified.send(:define_method, :class) do
              @@klass
            end

            modified.send(:define_method, :is_a?) do |query_class|
              @@klass.ancestors.include? query_class
            end

            modified
          end

        end

        def as_contact(contact)
          @parent = contact.is_a?(Contact) ? contact : Contact.new(Id: contact)
          self
        end

      end
    end
  end
end
