class NameValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    return unless value.kind_of? String

    is_taken = value =~ /\A(?:#{Section::VARIANTS}|animes|mangas|all|contests)\Z/ ||
      group_presence(record, value) || user_presence(record, value)

    if is_taken
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.taken'))
    end
  end

private
  def group_presence record, value
    if record.kind_of? Group
      Group.where.not(id: record.id).where(name: value).any?
    else
      Group.where(name: value).any?
    end
  end

  def user_presence record, value
    if record.kind_of? User
      User.where.not(id: record.id).where(nickname: value).any?
    else
      User.where(nickname: value).any?
    end
  end
end
