class Moderations::ArticlesController < ModerationsController
  load_and_authorize_resource

  PENDING_PER_PAGE = 15
  PROCESSED_PER_PAGE = 25

  def index
    og page_title: i18n_t('page_title')

    @moderators = User
      .where("roles && '{#{Types::User::Roles[:article_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }

    @processed = QueryObjectBase.new(processed_scope).paginate(@page, PROCESSED_PER_PAGE)
    @pending = pending_scope
  end

  def accept
    @resource.accept! approver: current_user
    redirect_back fallback_location: moderations_articles_url
  end

  def reject
    @resource.reject! approver: current_user
    redirect_back fallback_location: moderations_articles_url
  end

  def cancel
    @resource.cancel!
    redirect_back fallback_location: moderations_articles_url
  end

private

  def processed_scope
    Article
      .where(moderation_state: %i[accepted rejected])
      .where(state: :published)
      .includes(:user, :approver, :topics)
      .order(created_at: :desc)
  end

  def pending_scope
    Article
      .where(moderation_state: :pending)
      .where(state: :published)
      .includes(:user, :approver, :topics)
      .order(created_at: :desc)
      .limit(PENDING_PER_PAGE)
  end
end
