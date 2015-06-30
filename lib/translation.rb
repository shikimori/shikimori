# NOTE use ActionView::Helpers::TranslationHelper#translate to translate views
module Translation
  def i18n_t key, options = {}
    yield options if block_given?
    # raises exception if no translation found
    I18n.t! "#{self.class.name.underscore}.#{key}", options
  rescue I18n::MissingTranslationData
    # fallback to default helper if fuzzy search fails
    I18n.t key, options
  end

  # только для существительных
  def i18n_i key, count = 1, ru_case = :subjective
    if I18n.locale == :en
      I18n.t "inflections.#{key}", count: count,
        default: key.pluralize(count)
    else
      I18n.t "inflections.cardinal.#{key}.#{ru_case}", count: count,
        default: "inflections.cardinal.#{key}.default".to_sym
    end
  end

  def i18n_io key, count_key
    raise ArgumentError unless [:one,:few].include? count_key

    if I18n.locale == :en
      I18n.t "inflections.#{key}.#{count_key}",
        default: key.pluralize(count_key == :one ? 1 : 2)
    else
      I18n.t "inflections.ordinal.#{key}.#{count_key}"
    end
  end

  # только для глаголов
  def i18n_v key, count = 1
    if I18n.locale == :en
      key
    else
      if count.kind_of? Integer
        I18n.t "verbs.#{key}", count: count
      else
        I18n.t "verbs.#{key}.#{count}"
      end
    end
  end
end
