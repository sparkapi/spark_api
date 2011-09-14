module FlexmlsApi
  module Models
    class Constraint
      FIELDS = [:RuleValue,:Value,:RuleFieldValue,:RuleField,:RuleName]
      attr_accessor *FIELDS
      def initialize(args)
        FIELDS.each { |f| send("#{f.to_s}=", args[f.to_s]) if args.include?(f.to_s) }
      end
      
      def to_s
        "#{self.RuleName}: Field(#{self.RuleField},#{self.RuleFieldValue}) Value(#{self.RuleValue},#{self.Value})"
      end
    end
  end
end

