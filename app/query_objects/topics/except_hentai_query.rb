class Topics::ExceptHentaiQuery
  method_object :scope

  def call
    @scope
      .joins("left join animes on animes.id=linked_id and linked_type='Anime'")
      .joins("left join mangas on mangas.id=linked_id and linked_type='Manga'")
      .where(
        <<~SQL.squish
          (animes.id is null or animes.is_censored=false) and
            (mangas.id is null or mangas.is_censored=false)
        SQL
      )
  end
end
