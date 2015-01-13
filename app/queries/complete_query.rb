module CompleteQuery
  AUTOCOMPLETE_LIMIT = 8

  # автодополнение
  def complete
    query = @klass.where(search_queries.join(' or ')).limit(AUTOCOMPLETE_LIMIT)
    query = query.where(@kind => true) if @kind.present?
    search_order(query).reverse
  end

private
  # выборка с учётом порядка search_queries
  def search_order query
    matched = search_queries.each_with_index.inject("<--!-->") do |memo, pair|
      condition = pair[0]
      index = pair[1]

      memo.sub '<--!-->', "(case when #{condition} then #{index} else <--!--> end)"
    end.sub('<--!-->', '999')

    query
      .select("#{@klass.table_name}.*, #{matched} as matched")
      .order("#{matched}, #{@klass.table_name}.name")
  end

  # варианты, которые будем перебирать при поиске
  def search_queries
    search_fields(@search).map {|field| field_search_query field }.flatten.compact
  end

  def field_search_query field
    table_field = transalted_field field
    [
      "#{table_field} = #{sanitize @search}",
      "#{table_field} = #{sanitize @search.gsub('_', ' ').strip}",
      "#{table_field} ilike #{sanitize "#{@search}%"}",
      "#{table_field} ilike #{sanitize "% #{@search}%"}",
      "#{table_field} ilike #{sanitize "%#{@search}%"}",
      (@search.include?(' ') ? "#{table_field} ilike #{sanitize "#{@search.split(' ').reverse.join(' ')}"}" : nil),
      (@search.include?(' ') ? "#{table_field} ilike #{sanitize "#{@search.split(' ').reverse.join('% ')}"}" : nil),
    ]
  end

  def sanitize query
    ActiveRecord::Base.sanitize query.sub(/\\+$/, '')
  end

  def transalted_field field_name
    "translate(#{field_name}, 'ёЁ', 'еЕ')"
  end
end
