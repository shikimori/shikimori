# Rescoring queries with multi-type fields
#   https://tryolabs.com/blog/2015/03/04/optimizing-elasticsearch-rescoring-queries-with-multi-type-fields/
# Strategies and Techniques for Relevance
#   https://www.compose.com/articles/elasticsearch-query-time-strategies-and-techniques-for-relevance-part-ii/
class Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit!]

  def call
    index_klass
      .query(query)
      .limit(@limit)
      .each_with_object({}) { |v, memo| memo[v.id.to_i] = v._data['_score'] }
  end

private

  def index_klass
    "#{self.class.name.split('::').last.pluralize}Index".constantize
  end

  def query
    name_fields_query
  end

  def name_fields_query
    {
      bool: { should: name_fields_match }
    }
  end

  def name_fields_match
    index_klass::NAME_FIELDS.flat_map { |field| field_query(field) }
  end

  def field_query field
    [
      { match: { "#{field}.original" => { query: @phrase, boost: 100 } } },
      { match: { "#{field}.edge": { query: @phrase, boost: 5 } } },
      { match: { "#{field}.ngram": { query: @phrase } } }
    ]
  end

  # def cache_key
  #   [
  #     type,
  #     @phrase,
  #     @limit,
  #     Elasticsearch::Reindex.time(type).to_i
  #   ]
  # end
end
