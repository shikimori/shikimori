module Translation
  # перевод фраз из декораторов, сервисов и т.д.
  def i18n_t key, options = {}
    yield options if block_given?

    klass = self.class == Class ? self : self.class
    I18n.t! "#{klass.name.underscore}.#{key}", options

  rescue I18n::MissingTranslationData
    I18n.t key, options
  end

  # только для существительных с количественными числительными
  def i18n_i key, count = 1, ru_case = :subjective
    count_key = count_key count

    translation = if I18n.russian?
      I18n.t "inflections.cardinal.#{key.downcase}.#{ru_case}.#{count_key}",
        default: "inflections.cardinal.#{key.downcase}.default".to_sym
    else
      I18n.t "inflections.#{key.downcase}.#{count_key}",
        default: key.to_s.downcase.gsub('_', ' ').pluralize(count_key == :one ? 1 : 2)
    end

    key != key.downcase ? translation.capitalize : translation
  end

  # только для существительных с порядковыми числительными
  def i18n_io key, count_key
    raise ArgumentError unless [:one, :few].include? count_key

    translation = if I18n.russian?
      I18n.t "inflections.ordinal.#{key.downcase}.#{count_key}"
    else
      I18n.t "inflections.#{key.downcase}.#{count_key}",
        default: key.to_s.gsub('_', ' ').pluralize(count_key == :one ? 1 : 2)
    end

    key != key.downcase ? translation.capitalize : translation
  end

  # только для прилагательных
  def i18n_a key, count_key, ru_case = :subjective
    raise ArgumentError unless [:one, :few].include? count_key

    I18n.russian? ? I18n.t("adjectives.#{key}.#{ru_case}.#{count_key}") : key
  end

  # только для глаголов
  def i18n_v key, count = 1
    I18n.russian? ?
      I18n.t("verbs.#{key}.#{count_key count}") :
      I18n.t("verbs.#{key}.#{count_key count}", default: key.gsub(/_/, ' '))
  end

  # слова из phrases.*.yml переводятся напрямую через I18n

  RU_COUNT_KEYS_TO_EN = {
    one: :one,
    few: :other,
    many: :other
  }

  def count_key count
    if count.kind_of?(Integer) || count.kind_of?(Float)
      I18n.russian? ? ru_count_key(count) : en_count_key(count)
    else
      I18n.russian? ? count : RU_COUNT_KEYS_TO_EN[count] || count
    end
  end

  def ru_count_key count
    number = count % 100
    return :many if number >= 5 && number <= 20

    number %= 10

    if number == 1
      :one
    elsif number >= 2 && number <= 4
      :few
    else
      :many
    end
  end

  def en_count_key count
    if count.zero?
      :zero
    elsif count == 1
      :one
    else
      :other
    end
  end
end
