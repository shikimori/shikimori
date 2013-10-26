module CompleteQuery
  AutocompleteLimit = 8

  # автодополнение
  def complete
    query = @klass.where(search_queries.join(' or ')).limit(AutocompleteLimit)
    query = query.where(@kind => true) if @kind.present?
    search_order(query)
        .all
        .reverse
  end

private
  # выборка с учётом порядка search_queries
  def search_order(query)
    matched = search_queries.each_with_index.inject("<--!-->") do |memo, pair|
      condition = pair[0]
      index = pair[1]

      memo.sub '<--!-->', "if(#{condition}, #{index}, <--!-->)"
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
        "#{column_name} = #{Entry.sanitize @search}",
        "#{column_name} = #{Entry.sanitize @search.gsub('_', ' ').strip}",
        "#{column_name} like #{Entry.sanitize "#{@search}%"}",
        "#{column_name} like #{Entry.sanitize "% #{@search}%"}",
        "#{column_name} like #{Entry.sanitize "%#{@search}%"}",
        (@search.include?(' ') ? "#{column_name} like #{Entry.sanitize "#{@search.split(' ').reverse.join(' ')}"}" : nil),
        (@search.include?(' ') ? "#{column_name} like #{Entry.sanitize "#{@search.split(' ').reverse.join('% ')}"}" : nil),
      ]
    end.flatten.uniq.compact
  end
end
