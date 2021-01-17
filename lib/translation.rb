# frozen_string_literal: true

module Translation
  # translate phrases from decorators, services, etc.
  def i18n_t key, options = {}
    yield options if block_given?

    klass = instance_of?(Class) ? self : self.class
    I18n.t! "#{klass.name.underscore}.#{key}", options
  rescue I18n::MissingTranslationData => e
    begin
      I18n.t key, options
    rescue I18n::NoTranslation
      raise e
    end
  end

  # only for nouns with cardinal numbers
  def i18n_i key, count = 1, ru_case = :subjective
    count_key = count_key count

    translation =
      if I18n.russian?
        I18n.t(
          "inflections.cardinal.#{key.downcase}.#{ru_case}.#{count_key}",
          default: "inflections.cardinal.#{key.downcase}.default"
        )
      else
        default = key.to_s.tr('_', ' ').pluralize(count_key == :one ? 1 : 2)
        I18n.t "inflections.#{key.downcase}.#{count_key}", default: default
      end

    key == key.downcase ? translation : translation.capitalize
  end

  # only for nouns with ordinal numbers
  def i18n_io key, count_key
    raise ArgumentError unless %i[one few].include? count_key

    translation =
      if I18n.russian?
        I18n.t "inflections.ordinal.#{key.downcase}.#{count_key}"
      else
        default = key.to_s.tr('_', ' ').pluralize(count_key == :one ? 1 : 2)
        I18n.t "inflections.#{key.downcase}.#{count_key}", default: default
      end

    key == key.downcase ? translation : translation.capitalize
  end

  # only for verbs
  def i18n_v key, count = 1, options = {}
    options = options.merge(default: key.tr('_', ' ')) unless I18n.russian?
    translation = I18n.t "verbs.#{key.downcase}.#{count_key(count)}", options

    key == key.downcase ? translation : translation.capitalize
  end

  # phrases from phrases.*.yml are translated directly with I18n

  private

  RU_COUNT_KEYS_TO_EN = { one: :one, few: :other, many: :other }

  def count_key count
    if count.is_a?(Integer) || count.is_a?(Float)
      I18n.russian? ? ru_count_key(count) : en_count_key(count)
    else
      I18n.russian? ? count : (RU_COUNT_KEYS_TO_EN[count] || count)
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
