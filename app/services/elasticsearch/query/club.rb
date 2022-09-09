class Elasticsearch::Query::Club < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit!]

private

  def query
    {
      bool: {
        must: [super]
      }
    }
  end

end
