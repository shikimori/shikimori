module Animes::Filters::Helpers
  def parse_terms terms
    terms.split(',').map do |term|
      is_negative = term[0] == '!'

      OpenStruct.new(
        value: is_negative ? term[1..-1] : term,
        is_negative: is_negative
      )
    end
  end

  def table_name
    @scope.table_name
  end

  def sanitize term
    ApplicationRecord.sanitize term
  end
end
