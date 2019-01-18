module CompleteQuery
  AUTOCOMPLETE_LIMIT = 16

  # автодополнение
  def complete
    query = @klass
      .where(Arel.sql(search_queries.join(' or ')))
      .limit(self.class::AUTOCOMPLETE_LIMIT)

    query = query.where(@kind => true) if @kind.present?
    search_order(query).reverse
  end

private

  # выборка с учётом порядка search_queries
  def search_order query
    matched = search_queries.each_with_index.inject('<--!-->') do |memo, pair|
      condition = pair[0]
      index = pair[1]

      memo.sub(
        '<--!-->',
        "(case when #{condition} then #{index} else <--!--> end)"
      )
    end.sub('<--!-->', '999')

    query
      .select("#{@klass.table_name}.*, #{matched} as matched")
      .order(Arel.sql("#{matched}, #{@klass.table_name}.name"))
  end

  # варианты, которые будем перебирать при поиске
  def search_queries
    search_fields(@search[0..90])
      .flat_map { |field| field_search_query field }
      .compact
  end

  def field_search_query field
    [
      "#{field} = #{sanitize @search}",
      "#{field} = #{sanitize @search.tr('_', ' ').strip}",
      "#{field} ilike #{sanitize "#{@search}%"}"
    ].compact.map { |condition| "#{field} != '' and (#{condition})" }
  end

  def sanitize query
    ApplicationRecord.sanitize query.sub(/\\+$/, '')
  end
end
