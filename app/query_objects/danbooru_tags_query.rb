class DanbooruTagsQuery
  include CompleteQuery
  AUTOCOMPLETE_LIMIT = 30

  def initialize phrase
    @search = phrase
    @klass = DanbooruTag
  end

private

  def search_fields _term
    [:name]
  end
end
