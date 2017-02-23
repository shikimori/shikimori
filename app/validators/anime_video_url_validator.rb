class AnimeVideoUrlValidator < UrlValidator
  def validate_each record, attribute, value
    super

    if record.errors[attribute].blank?
      check_uniqueness record, attribute, value
    end
  end

  private

  def check_uniqueness record, attribute, value
    duplicates = AnimeOnline::AnimeVideoDuplicates
      .call(value)
      .where.not(id: record.id)

    if duplicates.any?
      record.errors[attribute] << I18n.t('activerecord.errors.models.videos.attributes.url.taken')
    end
  end
end
