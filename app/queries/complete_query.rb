module CompleteQuery
  AutocompleteLimit = 8

  # автодополнение
  def complete
    query = @klass.where(search_queries.join(' or ')).limit(AutocompleteLimit)
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

    query.select("#{@klass.table_name}.*, #{matched} as matched")
        .order("#{matched}, #{@klass.table_name}.name")
  end

  # варианты, которые будем перебирать при поиске
  def search_queries
    fields = search_fields @search
    downcased = Unicode.downcase(@search)

    fields.map do |column_name|
      [
        "#{column_name} = #{sanitize @search}",
        "#{column_name} = #{sanitize @search.gsub('_', ' ').strip}",
        "#{column_name} ilike #{sanitize "#{@search}%"}",
        "#{column_name} ilike #{sanitize "% #{@search}%"}",
        "#{column_name} ilike #{sanitize "%#{@search}%"}",
        (@search.include?(' ') ? "#{column_name} ilike #{sanitize "#{@search.split(' ').reverse.join(' ')}"}" : nil),
        (@search.include?(' ') ? "#{column_name} ilike #{sanitize "#{@search.split(' ').reverse.join('% ')}"}" : nil),
      ]
    end.flatten.uniq.compact
  end

  def sanitize query
    ActiveRecord::Base.sanitize query.sub(/\\+$/, '')
  end
end
