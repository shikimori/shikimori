class Animes::CensoredPostersQuery
  method_object %i[klass! moderation_state!]

  def call
    Poster.active
      .joins(@klass.name.downcase.to_sym)
      .where("genre_v2_ids && '{#{censored_genre_v2_ids.join(',')}}'")
      .where(moderation_state:)
      .order(
        format(Animes::Filters::OrderBy::ORDER_SQL[:score], table_name: @klass.table_name)
      )
  end

private

  def censored_genre_v2_ids
    "#{@klass.name}GenresV2Repository".constantize.instance
      .select(&:temporarily_posters_disabled?)
      .pluck(:id)
  end
end
