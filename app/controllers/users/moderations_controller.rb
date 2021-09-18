class Users::ModerationsController < ProfilesController
  skip_before_action :set_breadcrumbs

  def comments
    authorize! :delete_all_comments, @resource

    Comment
      .where(is_summary: false, user_id: @resource.id)
      .each { |comment| faye.destroy comment }

    redirect_to moderation_profile_url @resource
  end

  def summaries
    authorize! :delete_all_summaries, @resource

    Comment
      .where(is_summary: true, user_id: @resource.id)
      .each { |comment| faye.destroy comment }

    redirect_to moderation_profile_url @resource
  end

  def topics
    authorize! :delete_all_topics, @resource

    Topic
      .where(user_id: @resource.id)
      .where(type: [nil, Topic.name, Topics::NewsTopic.name])
      .each { |topic| faye.destroy topic }

    redirect_to moderation_profile_url @resource
  end

  def critiques
    authorize! :delete_all_critiques, @resource

    Critique
      .where(user_id: @resource.id)
      .each { |review| faye.destroy review }

    redirect_to moderation_profile_url @resource
  end

private

  def faye
    @faye ||= FayeService.new current_user, nil
  end
end
