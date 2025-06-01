class RecommendationIgnoresController < ShikimoriController
  before_action :authenticate_user!

  TARGET_TYPES = %w[
    Anime
    Manga
  ]

  def create
    if(TARGET_TYPES.include?(params[:target_type]))
      render json: RecommendationIgnore.block(entry, current_user)
    else
      render json: { error: 'Incompatible target_type supplied' }, status: 422
    end
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
