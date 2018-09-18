# Deprecated
# TODO: Get rid of this class
class SimpleQueryBase
  extend DslAttribute
  dsl_attribute :decorate_page

  def fetch page, limit
    query
      .offset(limit * (page - 1))
      .limit(limit + 1)
  end

  def postload page, limit
    collection = decorate_page ?
      fetch(page, limit).decorate.to_a :
      fetch(page, limit).to_a

    [collection.take(limit), collection.size == limit + 1]
  end
end
