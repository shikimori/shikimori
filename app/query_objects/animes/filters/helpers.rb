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

  # разбитие на 2 группы по наличию !, плюс возможная обработка элементов
  def bang_split values, force_integer = false
    data = values.each_with_object(include: [], exclude: []) do |v, memo|
      memo[v.starts_with?('!') ? :exclude : :include] << v.sub('!', '')
    end

    if force_integer
      data[:include].map!(&:to_i)
      data[:exclude].map!(&:to_i)
    end

    if block_given?
      data[:include].map! { |v| yield v }
      data[:exclude].map! { |v| yield v }
    end

    data
  end

  def table_name
    @scope.table_name
  end

  def sanitize term
    ApplicationRecord.sanitize term
  end
end
