class AnimeVideoAuthorsQuery
  include CompleteQuery
  AUTOCOMPLETE_LIMIT = 30

  def initialize phrase
    @search = SearchHelper.unescape phrase
    @klass = AnimeVideoAuthor
  end

private

  def search_fields _term
    [:name]
  end

  def field_search_query field # rubocop:disable MethodLength, AbcSize
    table_field = transalted_field field
    [
      "#{table_field} = #{sanitize @search}",
      "#{table_field} = #{sanitize @search.tr('_', ' ').strip}",
      "#{table_field} ilike #{sanitize "#{@search}%"}",
      "#{table_field} ilike #{sanitize "% #{@search}%"}",
      "#{table_field} ilike #{sanitize "%#{@search}%"}",
      (
        @search.include?(' ') ?
          "#{table_field} ilike #{sanitize @search.split(' ').reverse.join(' ').to_s}" :
          nil
      ),
      (
        @search.include?(' ') ?
          "#{table_field} ilike #{sanitize @search.split(' ').reverse.join('% ').to_s}" :
          nil
      )
    ].compact.map { |condition| "#{table_field} != '' and (#{condition})" }
  end

  def transalted_field field_name
    "translate(#{field_name}, 'ёЁ', 'еЕ')"
  end
end
