class Moderations::CritiquesController < ModerationsController
  load_and_authorize_resource

  PENDING_PER_PAGE = 15
  PROCESSED_PER_PAGE = 25

  RULES_TOPIC_ID = 299_745

  def index
    og page_title: i18n_t('page_title')

    @moderators = User
      .where("roles && '{#{Types::User::Roles[:critique_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }

    @processed = QueryObjectBase.new(processed_scope).paginate(@page, PROCESSED_PER_PAGE)
    @pending = pending_scope

    @rules_topic = Topics::TopicViewFactory.new(false, false).find_by(id: RULES_TOPIC_ID)
  end

  def accept
    @resource.accept! approver: current_user
    redirect_back fallback_location: moderations_critiques_url
  end

  def reject
    @resource.reject! approver: current_user
    redirect_back fallback_location: moderations_critiques_url
  end

  def cancel
    @resource.cancel!
    redirect_back fallback_location: moderations_critiques_url
  end

private

  def processed_scope
    Critique
      .where(moderation_state: %i[accepted rejected])
      .where(locale: locale_from_host)
      .includes(:user, :approver, :target, :topics)
      .order(created_at: :desc)
  end

  def pending_scope
    Critique
      .where(moderation_state: :pending)
      .where(locale: locale_from_host)
      .includes(:user, :approver, :target, :topics)
      .order(created_at: :desc)
      .limit(PENDING_PER_PAGE)
  end
end
