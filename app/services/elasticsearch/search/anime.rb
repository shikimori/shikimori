# Rescoring queries with multi-type fields
#   https://tryolabs.com/blog/2015/03/04/optimizing-elasticsearch-rescoring-queries-with-multi-type-fields/
# Strategies and Techniques for Relevance
#   https://www.compose.com/articles/elasticsearch-query-time-strategies-and-techniques-for-relevance-part-ii/
class Elasticsearch::Search::Anime < Elasticsearch::Search::SearchBase
private

  def query
    {
      function_score: {
        query: {
          dis_max: {
            queries: fields_queries
          }
        },
        field_value_factor: {
          field: 'weight',
          modifier: 'log',
          factor: 1
        }
      }
    }
  end
end
