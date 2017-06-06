class Elasticsearch::Query::Collection < Elasticsearch::Query::QueryBase
  method_object %i[phrase locale limit]

private

  def query
    {
      bool: {
        must: [name_fields_query, locale_query]
      }
    }
  end

  def locale_query
    { term: { locale: @locale } }
  end

  def cache_key
    super + [@locale]
  end
end
