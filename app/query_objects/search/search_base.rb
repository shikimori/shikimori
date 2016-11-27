# how to order by id position
#   https://gist.github.com/cpjolicoeur/3590737#gistcomment-1606739
class Search::SearchBase
  method_object [:scope, :phrase, :ids_limit]
  attr_implement :search_klass

  def call
    search_ids = elastic_results.map { |v| v['_id'] }

    if search_ids.any?
      @scope.where(id: search_ids).order(order_sql(search_ids))
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
    "Elasticsearch::Search::#{self.class.name.split('::').last}".constantize
  end

  def order_sql search_ids
    ids = search_ids.join(',')

    <<-SQL.squish
      position(
        #{@scope.model.table_name}.id::text in #{@scope.sanitize ids}
      )
    SQL
  end
end

