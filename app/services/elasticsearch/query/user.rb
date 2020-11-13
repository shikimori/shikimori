class Elasticsearch::Query::User < Elasticsearch::Query::QueryBase
  private

  def query
    {
      function_score: {
        query: super,
        field_value_factor: {
          field: 'weight',
          modifier: 'none',
          factor: 1
        }
      }
    }
  end
end
