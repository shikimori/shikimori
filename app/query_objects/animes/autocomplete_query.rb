class Animes::AutocompleteQuery
  method_object [:scope, :phrase]

  LIMIT = 16

  def call
    Animes::SearchQuery.call scope: @scope, phrase: @phrase, ids_limit: LIMIT
  end
end
