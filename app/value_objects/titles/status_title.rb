class Titles::StatusTitle
  include Translation
  pattr_initialize :status, :klass

  def text
    status.to_s
  end

  def url_params
    # без nil из-за странного бага рельс когда находишься на странице
    # http://shikimori.local/animes/status/anons status/anons попадает
    # в сгенерённый url
    { season: nil, status: text, kind: nil }
  end

  def catalog_title
    I18n.t "animes_collection.menu.#{klass_key}.status.#{status}"
  end

  def short_title
    # I18n.t "enumerize.#{klass_key}.status.#{status}"
    i18n_t "#{klass_key}.#{status}"
  end

  def full_title
    I18n.t(
      "titles/collection_title.status.#{klass_key}.many_kinds.#{status}"
    ).first_upcase
  end

private

  def klass_key
    klass.name.underscore
  end
end
