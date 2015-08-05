module Translation
  # перевод фраз из декораторов, сервисов и т.д.
  def i18n_t key, options = {}
    yield options if block_given?

    klass = self.instance_of?(Class) ? self : self.class
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
        default: key.to_s.downcase.gsub('_', ' ').pluralize(count)
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

  # слова из phrases.*.yml переводятся напрямую через I18n

  def count_key count
    if count.kind_of? Integer
      I18n.russian? ? ru_count_key(count) : en_count_key(count)
    else
      count == :plural ? :other : count
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
