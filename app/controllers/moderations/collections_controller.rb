# TODO: migrate to cancancan
class Moderations::CollectionsController < ModerationsController
  before_action :authenticate_user!
  before_action :check_permissions

  PENDING_PER_PAGE = 15
  PROCESSED_PER_PAGE = 25

  def index
    og page_title: i18n_t('page_title')

    @moderators = User
      .where("roles && '{#{Types::User::Roles[:collection_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }

    @processed = QueryObjectBase.new(processed_scope).paginate(@page, PROCESSED_PER_PAGE)
    @pending = pending_scope
  end

  def accept
    @collection = Collection.find params[:id].to_i
    @collection.accept! current_user if @collection.can_accept?

    redirect_back fallback_location: moderations_collections_url
  end

  def reject
    @collection = Collection.find params[:id].to_i
    @collection.reject! current_user if @collection.can_reject?

    redirect_back fallback_location: moderations_collections_url
  end

private

  def check_permissions
    raise Forbidden unless current_user.collection_moderator? || current_user.admin?
  end

  def processed_scope
    Collection
      .where(moderation_state: %i[accepted rejected])
      .where(state: :published)
      .where(locale: locale_from_host)
      .includes(:user, :approver, :topics)
      .order(created_at: :desc)
  end

  def pending_scope
    Collection
      .where(moderation_state: :pending)
      .where(state: :published)
      .where(locale: locale_from_host)
      .includes(:user, :approver, :topics)
      .order(created_at: :desc)
      .limit(PENDING_PER_PAGE)
  end
end
