class StatusTitle
  include Translation
  pattr_initialize :status, :klass

  def text
    status.to_s
  end

  def url_params
    { type: nil, status: text }
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
      "titles/collection_title.status.#{klass_key}.many_types.#{status}"
    ).first_upcase
  end

private

  def klass_key
    klass.name.underscore
  end
end
