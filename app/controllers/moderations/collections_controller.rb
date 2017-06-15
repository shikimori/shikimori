# TODO: migrate to cancancan
class Moderations::CollectionsController < ModerationsController
  before_action :authenticate_user!
  before_action :check_permissions
  PENDING_PER_PAGE = 15

  def index
    @page_title = i18n_t 'page_title'

    @moderators = User
      .where(id: User::COLLECTIONS_MODERATORS - User::ADMINS)
      .sort_by { |v| v.nickname.downcase }

    @processed = postload_paginate(params[:page], 25) do
      Collection
        .where(moderation_state: %i[accepted rejected])
        .where(state: :published)
        .where(locale: locale_from_host)
        .includes(:user, :approver, :topics)
        .order(created_at: :desc)
    end

    # if user_signed_in? && current_user.collections_moderator?
    @pending = Collection
      .where(moderation_state: :pending)
      .where(state: :published)
      .where(locale: locale_from_host)
      .includes(:user, :approver, :topics)
      .order(created_at: :desc)
      .limit(PENDING_PER_PAGE)
    # end
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
    raise Forbidden unless current_user.collections_moderator?
  end
end
