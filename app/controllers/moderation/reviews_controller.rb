class Moderation::ReviewsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permissions

  def index
    @page_title = 'Модерация рецензий'

    @moderators = User.where(id: User::ReviewsModerators - [1]).all.sort_by { |v| v.nickname.downcase }
    @processed = postload_paginate(params[:page], 25) do
      Review
        .where(state: ['accepted', 'rejected'])
        .includes(:user, :approver, :target)
        .order('created_at desc')
    end

    if user_signed_in? && current_user.moderator?
      @pending = Review
          .where(state: 'pending')
          .includes(:user, :approver, :target)
          .order('created_at desc')
          .limit(15)
    end
  end

  def accept
    @review = Review.find params[:id].to_i
    @review.accept! current_user if @review.can_accept?

    redirect_to_back_or_to moderation_reviews_url
  end

  def reject
    @review = Review.find params[:id].to_i
    @review.reject! current_user if @review.can_reject?

    redirect_to_back_or_to moderation_reviews_url
  end

private
  def check_permissions
    raise Forbidden unless current_user.reviews_moderator?
  end
end
