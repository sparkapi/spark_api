module SparkApi
  module Models
    module Associations

      attr_accessor :associations

      def has_many(name, options = {})
        add_to_associations :has_many, name.to_sym
        init_has_many_associations name.to_s, options
      end

      def includes_association?(name)
        unless @associations.nil?
          @associations.each_value { |associations_by_type| return true if associations_by_type.include? name.to_sym }
        end
        false
      end


      private
      def create_method(name, &block)
        self.class.__send__( :define_method, name, &block )
      end

      def add_to_associations(type, name)
        @associations = {} if @associations.nil?
        @associations[type] = [] if @associations[type].nil?
        @associations[type] << name
      end


       def init_has_many_associations(name, options = {})
         self.class.__send__(:attr_accessor, name)

          create_method(name.to_sym) {
            associated_objects = instance_variable_get( "@" + name )

            if associated_objects.nil?
              if self.persisted?
                id = self.attributes['Id']
                resource = self.class.element_name
                subresource = name.gsub('_', '')
                subresource_class = options[:subresource_class]
                associated_objects = instance_variable_set( "@" + name, subresource_class.collect(connection.get("/#{resource}/#{id}/#{subresource}")))
              else
                associated_objects = instance_variable_set( "@" + name, [])
              end
            end
            associated_objects
         }
       end

    end
  end
end