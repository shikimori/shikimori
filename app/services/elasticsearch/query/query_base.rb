# Rescoring queries with multi-type fields
#   https://tryolabs.com/blog/2015/03/04/optimizing-elasticsearch-rescoring-queries-with-multi-type-fields/
# Strategies and Techniques for Relevance
#   https://www.compose.com/articles/elasticsearch-query-time-strategies-and-techniques-for-relevance-part-ii/
class Elasticsearch::Query::QueryBase
  method_object %i[phrase limit]

  INDEX = Elasticsearch::Config::INDEX
  EXPIRES_IN = 1.hour

  def call
    Rails.cache.fetch(cache_key, expires_in: EXPIRES_IN) { parse api_call }
  end

private

  def type
    self.class.name.split('::').last.downcase
  end

  def api_call
    Elasticsearch::Client.instance.get(
      "#{INDEX}_#{type.pluralize}/#{type.pluralize}/_search",
      from: 0,
      size: @limit,
      query: query
    )
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
    "Elasticsearch::Data::#{type.capitalize}::NAME_FIELDS".constantize
      .flat_map { |field| field_query(field) }
  end

  def field_query field
    [
      { match: { "#{field}.original" => { query: keyword, boost: 6 } } },
      { match: { field => { query: keyword, boost: 3 } } },
      { match: { "#{field}.ngram": { query: keyword } } }
    ]
  end

  def parse api_results
    # api_results['hits']['hits'].select do |hit|
      # hit['_score'] >= api_results['hits']['max_score'] / 6.0
    # end
    api_results['hits']['hits']
  end

  def keyword
    @phrase.downcase
  end

  def cache_key
    [
      type,
      @phrase,
      @limit,
      Elasticsearch::Reindex.time(type).to_i
    ]
  end
end
