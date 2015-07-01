# NOTE use ActionView::Helpers::TranslationHelper#translate to translate views
module Translation
  # перевод фразы из декоратора
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
    if I18n.russian?
      I18n.t "inflections.cardinal.#{key}.#{ru_case}", count: count,
        default: "inflections.cardinal.#{key}.default".to_sym

    else
      I18n.t "inflections.#{key}", count: count,
        default: key.pluralize(count)
    end
  end

  # только для количественных существительных
  def i18n_io key, count_key
    raise ArgumentError unless [:one,:few].include? count_key

    translation = if I18n.russian?
      I18n.t "inflections.ordinal.#{key.downcase}.#{count_key}"
    else
      I18n.t "inflections.#{key.downcase}.#{count_key}",
        default: key.pluralize(count_key == :one ? 1 : 2)
    end

    key != key.downcase ? translation.capitalize : translation
  end

  # только для глаголов
  def i18n_v key, count = 1
    if I18n.russian?
      if count.kind_of? Integer
        I18n.t "verbs.#{key}", count: count
      else
        I18n.t "verbs.#{key}.#{count}"
      end

    else
      key
    end
  end
end
