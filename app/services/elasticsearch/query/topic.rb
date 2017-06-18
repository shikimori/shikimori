class Elasticsearch::Query::Topic < Elasticsearch::Query::QueryBase
  method_object %i[phrase locale forum_id limit]

private

  def query
    {
      bool: {
        must: [name_fields_query, locale_query, forum_id_query]
      }
    }
  end

  def locale_query
    { term: { locale: @locale } }
  end

  def forum_id_query
    { term: { forum_id: @forum_id } }
  end

  def cache_key
    super + [@locale, @forum_id]
  end
end
