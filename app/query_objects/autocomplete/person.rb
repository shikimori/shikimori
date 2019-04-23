class Autocomplete::Person < Autocomplete::AutocompleteBase
  method_object %i[scope phrase is_mangaka is_producer is_seyu]

  def call
    autocomplete_klass.call(
      scope: @scope,
      phrase: @phrase,
      ids_limit: LIMIT,
      is_mangaka: @is_mangaka,
      is_producer: @is_producer,
      is_seyu: @is_seyu
    )
  end
end
