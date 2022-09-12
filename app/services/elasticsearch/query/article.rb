class Elasticsearch::Query::Article < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit!]
end
