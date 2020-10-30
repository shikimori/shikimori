class Elasticsearch::Query::Licensor < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit! kind!]

  def call
    index_klass
      .query(query)
      .limit(@limit)
      .map(&:name)
  end

private

  def query
    {
      bool: {
        must: [super, kind_query]
      }
    }
  end

  def kind_query
    { term: { kind: @kind } }
  end
end
