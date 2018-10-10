class Users::ModerationsController < ProfilesController
  skip_before_action :set_breadcrumbs

  def comments
    authorize! :delete_all_comments, @resource
    Comment.where(user_id: @resource.id).each do |comment|
      faye.destroy comment
    end

    redirect_to moderation_profile_url @resource
  end

  def topics
    authorize! :delete_all_topics, @resource
    Topic.where(user_id: @resource.id).each do |topic|
      faye.destroy topic
    end

    redirect_to moderation_profile_url @resource
  end

  def reviews
    authorize! :delete_all_reviews, @resource
    Review.where(user_id: @resource.id).each do |review|
      faye.destroy review
    end

    redirect_to moderation_profile_url @resource
  end

private

  def faye
    @faye ||= FayeService.new current_user, nil
  end
end
