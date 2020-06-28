class VersionsView < ViewObjectBase
  instance_cache :moderators, :pending, :processed

  PER_PAGE = 25

  def processed_scope
    Moderation::ProcessedVersionsQuery
      .fetch(type_param, h.params[:created_on])
  end

  def pending_scope
    Moderation::VersionsItemTypeQuery.fetch(type_param)
  end

  def moderators_scope nickname
    return User.none if nickname.blank?

    User
      .where(id: processed_scope.distinct.select(:moderator_id).except(:order))
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
    processed_scope
      .paginate(page, PER_PAGE)
      .transform(&:decorate)
  end

  def pending
    pending_scope
      .includes(:user, :moderator)
      .where(state: :pending)
      .order(:created_at)
      .paginate(page, PER_PAGE)
      .transform(&:decorate)
  end

  def next_page_url is_pending
    h.moderations_versions_url(
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
