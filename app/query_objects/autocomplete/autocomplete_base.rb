class Autocomplete::AutocompleteBase
  method_object %i[scope phrase]

  LIMIT = 16

  def call
    return [] if @phrase.blank?

    autocomplete_klass.call(
      scope: @scope,
      phrase: @phrase,
      ids_limit: LIMIT
    )
  end

private

  def autocomplete_klass
    "Search::#{self.class.name.split('::').last}".constantize
  end
end
