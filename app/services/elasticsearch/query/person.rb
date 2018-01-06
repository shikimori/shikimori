class Elasticsearch::Query::Person < Elasticsearch::Query::QueryBase
  method_object %i[phrase limit is_mangaka is_seyu is_producer]

private

  def query
    {
      bool: {
        must: [
          super,
          mangaka_query,
          seyu_query,
          producer_query
        ].compact
      }
    }
  end

  def mangaka_query
    { term: { is_mangaka: true } } if @is_mangaka
  end

  def seyu_query
    { term: { is_seyu: true } } if @is_seyu
  end

  def producer_query
    { term: { is_producer: true } } if @is_producer
  end

  def cache_key
    super + [@is_mangaka, @is_seyu, @is_producer]
  end
end
