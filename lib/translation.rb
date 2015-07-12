# NOTE use ActionView::Helpers::TranslationHelper#translate to translate views
module Translation
  # перевод фраз из декораторов, сервисов и т.д.
  def i18n_t key, options = {}
    yield options if block_given?
    I18n.t! "#{self.class.name.underscore}.#{key}", options

  rescue I18n::MissingTranslationData
    I18n.t key, options
  end

  # только для существительных с количественными числительными
  def i18n_i key, count = 1, ru_case = :subjective
    count_key = count_key count

    if I18n.russian?
      I18n.t "inflections.cardinal.#{key}.#{ru_case}.#{count_key}",
        default: "inflections.cardinal.#{key}.default".to_sym
    else
      I18n.t "inflections.#{key}.#{count_key}",
        default: key.gsub('_', ' ').pluralize(count)
    end
  end

  # только для существительных с порядковыми числительными
  def i18n_io key, count_key
    raise ArgumentError unless [:one, :few].include? count_key

    translation = if I18n.russian?
      I18n.t "inflections.ordinal.#{key.downcase}.#{count_key}"
    else
      I18n.t "inflections.#{key.downcase}.#{count_key}",
        default: key.gsub('_', ' ').pluralize(count_key == :one ? 1 : 2)
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

  # для перевода частовстречаемых фраз и слов
  def i18n_p key
    if I18n.russian?
      I18n.t "phrases.#{key}"
    else
      I18n.t "phrases.#{key}", default: key.gsub('_', ' ').capitalize
    end
  end

  def count_key count
    if count.kind_of? Integer
      { one: 1, few: 2 }.key(count) || :many
    else
      count
    end
  end
end
