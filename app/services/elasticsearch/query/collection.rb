class Elasticsearch::Query::Collection < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit!]
end
