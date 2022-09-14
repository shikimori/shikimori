class Comments::UserQuery < QueryObjectBase
  def self.fetch user
    scope = Comment
      .where(user_id: user.id)
      .order(id: :desc)

    new(scope)
  end

  def search phrase
    return self if phrase.blank?

    chain @scope.where("body ilike #{ApplicationRecord.sanitize "%#{phrase}%"}")
  end

  def filter_by_policy user
    lazy_filter do |comment|
      Comment::AccessPolicy.allowed? comment, user
    end
  end
end
