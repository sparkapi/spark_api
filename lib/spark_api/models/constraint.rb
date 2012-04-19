module SparkApi
  module Models
    class Constraint
      ATTRIBUTES = ["RuleValue","Value","RuleFieldValue","RuleField","RuleName"]
      attr_accessor *ATTRIBUTES
      def initialize(args)
        ATTRIBUTES.each { |f| send("#{f}=", args[f]) if args.include?(f) || args.include?(f.to_sym) }
      end
      
      def to_s
        "#{self.RuleName}: Field(#{self.RuleField},#{self.RuleFieldValue}) Value(#{self.RuleValue},#{self.Value})"
      end
    end
  end
end

