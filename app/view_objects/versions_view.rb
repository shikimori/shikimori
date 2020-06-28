class VersionsView < ViewObjectBase
  instance_cache :moderators, :pending, :processed

  PER_PAGE = 25

  def searched_user
    return unless h.current_user.staff? && h.params[:user_id].present?

    @searched_user ||= User.find_by id: h.params[:moderator_id]
  end

  def searched_moderator
    return unless h.current_user.staff? && h.params[:moderator_id].present?

    @searched_moderator ||= User.find_by id: h.params[:moderator_id]
  end

  def processed_scope
    Moderation::ProcessedVersionsQuery
      .fetch(type_param, h.params[:created_on])
  end

  def pending_scope
    Moderation::VersionsItemTypeQuery.fetch(type_param)
  end

  def moderators_scope nickname
    return User.none if nickname.blank?

    scope = processed_scope
      .where.not(state: %i[auto_accepted deleted])
      .distinct
      .select(:moderator_id)
      .except(:order)

    User
      .where(id: scope)
      .where('nickname ilike ?', "#{nickname}%")
  end

  def authors_scope nickname
    return User.none if nickname.blank?

    User
      .where(id: processed_scope.distinct.select(:user_id).except(:order))
      .or(User.where(id: pending_scope.distinct.pluck(:user_id)))
      .where('nickname ilike ?', "#{nickname}%")
  end

  def processed
    scope = processed_scope

    scope.where! user_id: searched_user.id if searched_user
    scope.where! moderator_id: searched_moderator.id if searched_moderator

    scope
      .paginate(page, PER_PAGE)
      .transform(&:decorate)
  end

  def pending
    scope = pending_scope

    scope.where! user_id: searched_user.id if searched_user
    scope.where! moderator_id: searched_moderator.id if searched_moderator

    scope
      .includes(:user, :moderator)
      .where(state: :pending)
      .order(:created_at)
      .paginate(page, PER_PAGE)
      .transform(&:decorate)
  end

  def next_page_url is_pending
    h.current_url(
      page: page + 1,
      type: h.params[:type],
      created_on: h.params[:created_on],
      is_pending: is_pending ? '1' : '0'
    )
  end

  def moderators
    type_suffix = h.params[:type] + '_' if h.params[:type] && h.params[:type] != 'content'
    role = "version_#{type_suffix}moderator"

    User
      .where("roles && '{#{role}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def type_param
    h.params[:type] || :all_content
  end
end
