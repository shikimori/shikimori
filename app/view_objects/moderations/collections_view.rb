class Moderations::CollectionsView < ViewObjectBase
  instance_cache :moderators, :pending, :processed

  PENDING_PER_PAGE = 15
  PROCESSED_PER_PAGE = 25

  def processed
    QueryObjectBase.new(apply_filters(processed_scope))
      .paginate(page, PROCESSED_PER_PAGE)
  end

  def pending
    QueryObjectBase.new(apply_filters(pending_scope))
      .paginate(page, PENDING_PER_PAGE)
  end

  def moderators
    @moderators ||= User
      .where("roles && '{#{Types::User::Roles[:collection_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |user| user.nickname.downcase }
  end

  def authors_scope nickname
    return User.none if nickname.blank?

    User
      .where(id: processed_scope.distinct.except(:order, :includes).select(:user_id))
      .or(User.where(id: pending_scope.distinct.except(:order, :includes).select(:user_id)))
      .where('nickname ilike ?', "#{nickname}%")
  end

  def filtered_user
    return if h.params[:user_id].blank?

    @filtered_user ||= User.find_by id: h.params[:user_id]
  end

private

  def processed_scope
    collections_scope
      .where(moderation_state: %i[accepted rejected])
  end

  def pending_scope
    collections_scope
      .where(moderation_state: :pending)
  end

  def collections_scope
    Collection
      .where(state: :published)
      .includes(:user, :approver, :topic)
      .order(created_at: :desc)
  end

  def apply_filters scope
    return scope unless h.can? :filter, Collection

    scope = scope.where user_id: filtered_user.id if filtered_user
    scope = scope.where('name ilike ?', "%#{h.params[:name]}%")

    scope
  end
end
