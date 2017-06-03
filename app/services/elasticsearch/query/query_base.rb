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
    Elasticsearch::Client.instance.get "#{INDEX}/#{type}/_search",
      from: 0,
      size: @limit,
      query: query
  end

  def query
    {
      bool: { should: fields_queries }
    }
  end

  def fields_queries
    "Elasticsearch::Data::#{type.capitalize}::TEXT_SEARCH_FIELDS".constantize
      .map { |field| field_query(field) }
  end

  def field_query field
    {
      bool: {
        should: [
          { match: { "#{field}.original" => { query: keyword, boost: 6 } } },
          { match: { field => { query: keyword, boost: 3 } } },
          { match: { "#{field}.ngram": { query: keyword } } }
        ]
      }
    }
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
      Elasticsearch::Reindex.time
    ]
  end
end
