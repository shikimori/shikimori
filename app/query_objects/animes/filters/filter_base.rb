class Animes::Filters::FilterBase
  extend DslAttribute

  method_object :scope, :value

  dsl_attribute :is_integer, false
  dsl_attribute :dry_type

  delegate :positives, :negatives, to: :terms

private

  def terms
    @terms ||= Animes::Filters::Terms.new(fixed_value, dry_type)
  end

  # can be overriden in child class
  def fixed_value
    @value
  end

  def table_name
    @scope.table_name
  end

  def sanitize term
    ApplicationRecord.sanitize term
  end

  def fail_with_negative!
    dry_type["!#{negatives[0]}"]
  end
end
