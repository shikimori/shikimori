class NameValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    return unless value.kind_of? String

    is_taken = value =~ /\A(?:#{Section::VARIANTS}|animes|mangas|all|contests|users)\Z/ ||
      presence(record, value, Group, :name) || presence(record, value, User, :nickname)

    if is_taken
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.taken'))
    end
  end

private

  def presence record, value, klass, field
    query = if record.kind_of? klass
      klass.where.not(id: record.id)
    else
      klass
    end

    query.where("#{postgres_word_normalizer field} = #{postgres_word_normalizer '?'}", value).any?
  end

  def postgres_word_normalizer text
    "translate(lower(unaccent(#{text})), 'абвгдеёзийклмнопрстуфхць', 'abvgdeezijklmnoprstufхc`')"
  end
end
