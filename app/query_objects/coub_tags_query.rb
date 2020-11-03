class CoubTagsQuery
  include CompleteQuery
  AUTOCOMPLETE_LIMIT = 30

  def initialize phrase
    @search = phrase
    @klass = CoubTag
  end

private

  def search_fields _term
    [:name]
  end
end
