module FlexmlsApi
  module Models
    class Constraint
      ATTRIBUTES = ["RuleValue","Value","RuleFieldValue","RuleField","RuleName"]
      attr_accessor *ATTRIBUTES
      def initialize(args)
        ATTRIBUTES.each { |f| send("#{f}=", args[f]) if args.include?(f) || args.include?(f.to_sym) }
      end
      
      def to_s
        msg = ""
        case self.RuleName
=begin
 TODO these. someday. Maybe next week.
        when 'DisallowHtml'
        when 'MinLength'
        when 'MaxLength'
        when 'LargerOnly'
        when 'LargerOrEqualOnly'
        when 'SmallerOnly'
        when 'SmallerOrEqualOnly'
        when 'MaxIncreasePercent'
        when 'MinIncreasePercent'
        when 'MaxDecreasePercent'
        when 'MinDecreasePercent'
        when 'MaxIncreaseValue'
        when 'MinIncreaseValue'
        when 'MaxDecreaseValue'
        when 'MinDecreaseValue'
        when 'MinDaysBefore'
        when 'MinDaysAfter'
        when 'MaxDaysBefore'
        when 'MaxDaysAfter'
        when 'MaxValue'
        when 'RequireDecimal'
        when 'RequireTwoDecimal'
        when 'DisallowPhone'
=end
        when 'MinValue'
          msg = "The minimum value for this field is #{self.RuleValue}"
        when 'DisallowDecimal'
          msg = "Decimal places may not be used in this field"
        end
        msg

      end
    end
  end
end

