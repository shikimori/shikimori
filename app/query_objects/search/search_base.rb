# how to order by id position
#   https://gist.github.com/cpjolicoeur/3590737#gistcomment-1606739
class Search::SearchBase
  method_object %i[scope! phrase! ids_limit!]

  def call
    search_ids = @phrase.blank? ? [] : elastic_results.keys

    if search_ids.any?
      @scope
        .where(id: search_ids)
        .except(:order)
        .order(order_sql(search_ids))
    else
      @scope.none
    end
  end

private

  def elastic_results
    search_klass.call(
      phrase: @phrase,
      limit: @ids_limit
    )
  end

  def search_klass
    "Elasticsearch::Query::#{self.class.name.split('::').last}".constantize
  end

  def order_sql search_ids
    ids = search_ids.join(',')

    Arel.sql(
      <<-SQL.squish
        position(
          concat(#{@scope.model.table_name}.id::text, ',') in
            #{ApplicationRecord.sanitize "#{ids},"}
        )
      SQL
    )
  end
end
