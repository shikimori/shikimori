class Elasticsearch::Query::Licensor < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit! kind!]

  def call
    index_klass
      .query(query)
      .limit(@limit)
      .map(&:name)
  end

private

  def query # rubocop:disable MethodLength
    {
      function_score: {
        query: {
          dis_max: {
            queries: [{
              bool: {
                must: [super, kind_query]
              }
            }]
          }
        },
        field_value_factor: {
          field: 'weight',
          modifier: 'none',
          factor: 1
        }
      }
    }
  end

  def kind_query
    { term: { kind: Types::Licensor::Kind[@kind] } }
  end
end
