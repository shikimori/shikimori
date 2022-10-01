class Elasticsearch::Query::Club < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit!]
end
