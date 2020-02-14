class Animes::Filters::FilterBase
  extend DslAttribute

  method_object :scope, :value

  dsl_attribute :is_integer, false
  dsl_attribute :dry_type

  delegate :positives, :negatives, to: :terms

private

  def terms
    @terms ||= Animes::Filters::Terms.new(@value, dry_type)
  end

  def parse_terms value
    terms = value.split(',').map do |term|
      is_negative = term[0] == '!'

      OpenStruct.new(
        value: is_negative ? term[1..-1] : term,
        is_negative: is_negative
      )
    end

    Animes::Filters::Terms.new(terms)
  end

  def table_name
    @scope.table_name
  end

  def sanitize term
    ApplicationRecord.sanitize term
  end
end
