class RecommendationIgnoresController < ShikimoriController
  before_action :authenticate_user!

  def create
    render json: RecommendationIgnore.block(entry, current_user)
  end

  def cleanup
    current_user
      .recommendation_ignores
      .where(target_type: klass.name)
      .delete_all

    render json: { notice: i18n_t("ignores_cleared.#{params[:target_type]}") }
  end

private

  def entry
    klass.find params[:target_id]
  end

  def klass
    params[:target_type].capitalize.constantize
  end
end
