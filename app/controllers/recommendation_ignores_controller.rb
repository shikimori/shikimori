class RecommendationIgnoresController < ApplicationController
  before_filter :authenticate_user!

  def create
    render json: RecommendationIgnore.block(entry, current_user)
  end

  def cleanup_warning
  end

  def cleanup
    current_user.recommendation_ignores.where(target_type: klass.name).delete_all
    redirect_to user_url(current_user), notice: "Очистка списка заблокированных рекомендаций #{params[:target_type] == 'anime' ? 'аниме' : 'манги'} завершена"
  end

private
  def entry
    klass.find params[:target_id]
  end

  def klass
    params[:target_type].capitalize.constantize
  end
end
