class QueryObjectBase
  def fetch page, limit
    query
      .offset(limit * (page-1))
      .limit(limit + 1)
  end

  def postload page, limit
    collection = fetch(page, limit).to_a
    [collection.take(limit), collection.size == limit+1]
  end
end
