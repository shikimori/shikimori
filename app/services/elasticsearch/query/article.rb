class Elasticsearch::Query::Article < Elasticsearch::Query::QueryBase
  method_object %i[phrase! limit! locale!]

private

  def query
    {
      bool: {
        must: [super, locale_query]
      }
    }
  end

  def locale_query
    { term: { locale: @locale } }
  end

  # def cache_key
  #   super + [@locale]
  # end
end
