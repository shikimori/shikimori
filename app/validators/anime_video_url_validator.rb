class AnimeVideoUrlValidator < UrlValidator
  def validate_each(record, attribute, value)
    super
    check_uniqueness(record, attribute, value) if record.errors[attribute].blank?
  end

  private

  def check_uniqueness(record, attribute, value)
    link = value.match(/https?:\/\/(.*)/)[1]
    duplicate = AnimeVideo
      .where(anime_id: record.anime_id)
      .where(url: ["http://#{link}", "https://#{link}"])
      .first

    if duplicate
      record.errors[attribute] << I18n.t('activerecord.errors.models.videos.attributes.url.taken')
    end
  end
end
