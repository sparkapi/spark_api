module SparkApi
  module Models
    module Dirty

      def changed?
        changed.any?
      end

      def associations_changed?
        changed_associated_objects.any?
      end

      # array with all the associated objects that have changed or are new
      def changed_associated_objects
        cao = []
          changed_associations.each do |ca|
            __send__(ca).select{|obj| !obj.destroyed? }.each do |obj|

              # If the persisted object is not a subresource of the current resource, we'll create a new resource for it
              if obj.persisted? && !obj.ResourceUri.include?(__send__(:Id))
                obj.attributes.delete("Id")
                obj.attributes.delete("ResourceUri")
              end
              cao << obj if obj.changed? || obj.new?
            end
          end
        cao
      end

      def changed
        changed_attributes.keys
      end

      def changes
        Hash[changed.map {|attr| [attr, attribute_change(attr)] }]
      end

      def previous_changes
        @previously_changed
      end

      # hash with changed attributes and their original values
      def changed_attributes
        @changed_attributes ||= {}
      end

      # array with the associations that might have gotten changed
      def changed_associations
          @changed_associations ||= []
      end

      # hash with changed attributes and their new values
      def dirty_attributes
        changed.inject({}) { |h, k| h[k] = attributes[k]; h }
      end

      private

      def reset_dirty
        @previously_changed = changed_attributes
        @changed_attributes.clear
      end


      def reset_changed_associations
        changed_associations.each do |ca|
          __send__("#{ca}=".to_sym, nil)
        end
      end

      def attribute_changed?(attr)
        changed.include?(attr)
      end

      def attribute_change(attr)
        [changed_attributes[attr], __send__(attr)] if attribute_changed?(attr)
      end

      def attribute_will_change!(attr)
        begin
          value = __send__(attr)
          value = value.duplicable? ? value.clone : value
        rescue TypeError, NoMethodError; end

        changed_attributes[attr] = value unless changed.include?(attr)
      end

      def associations_will_change!(name)
        changed_associations << name.to_sym unless changed_associations.include? name.to_sym
      end

    end
  end
end
