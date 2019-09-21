class VersionsView < ViewObjectBase
  instance_cache :moderators, :pending, :processed, :processed_query
  per_page_limit 25

  def processed
    processed_query.first.map(&:decorate)
  end

  def postloader?
    processed_query.second
  end

  def pending
    Moderation::VersionsItemTypeQuery.call(type_param)
      .includes(:user, :moderator)
      .where(state: :pending)
      .order(:created_at)
      .limit(per_page_limit)
      .decorate
  end

  def next_page_url
    h.moderations_versions_url(
      page: page + 1,
      type: type_param,
      created_on: h.params[:created_on]
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

private

  def processed_query
    Moderation::ProcessedVersionsQuery
      .new(type_param, h.params[:created_on])
      .postload(page, per_page_limit)
  end
end
