class StudiosController < ShikimoriController
  SELECT_SQL = <<-SQL.squish
    studios.*,
    count(animes.id) as animes_count,
    max(animes.aired_on_computed) as max_year,
    min(animes.aired_on_computed) as min_year
  SQL

  def index
    og page_title: i18n_t('page_title'), description: i18n_t('description')

    @collection = Studio
      .joins('left join animes on studios.id = any(animes.studio_ids)')
      .where.not(animes: { kind: :special })
      .group('studios.id')
      .select(SELECT_SQL)
      .order('animes_count desc')
  end
end
