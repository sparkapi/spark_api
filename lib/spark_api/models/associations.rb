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
        klass = options[:class]

        create_method(name.to_sym) do |opts = {}|
          associated_objects = instance_variable_get("@#{name}")
          base_path = "/#{self.class.element_name}/#{self.attributes['Id']}"

          if associated_objects.nil?
            associated_objects = []
            if self.persisted?
              associated_objects = klass.collect(connection.get("#{base_path}/#{klass.element_name}", opts))
            end
            associated_objects = instance_variable_set("@#{name}", associated_objects)
          end

          singleton = class << associated_objects; self; end
          singleton.send(:define_method, :find) do |id, opts = {}|
            resp = SparkApi.client.get("#{base_path}/#{klass.element_name}/#{id}", opts)
            klass.new(resp.first)
          end

          associated_objects
        end
      end

    end
  end
end
