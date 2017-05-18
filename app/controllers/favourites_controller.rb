class FavouritesController < ShikimoriController
  before_action :authenticate_user!

  def create
    favorites_limit = Favourite::LIMITS[params[:linked_type].downcase.to_sym]
    raise CanCan::AccessDenied unless favorites_limit

    added_count = Favourite
      .where(
        linked_type: params[:linked_type],
        user_id: current_user.id,
        kind: params[:kind] || ''
      )
      .size

    if added_count >= favorites_limit
      render(
        json: [i18n_t(
          "cant_add.#{params[:linked_type].downcase}",
          limit: favorites_limit
        )],
        status: :unprocessable_entity
      )
    else
      Favourite.create!(
        linked_type: params[:linked_type],
        linked_id: params[:linked_id],
        user_id: current_user.id,
        kind: params[:kind] || ''
      )

      render json: { success: true, notice: i18n_t('added') }
    end

  rescue ActiveRecord::RecordNotUnique
    render json: { success: true, notice: i18n_t('added') }
  end

  def destroy
    Favourite
      .where(
        linked_type: params[:linked_type],
        linked_id: params[:linked_id],
        user_id: current_user.id,
      )
      .destroy_all

    render json: { success: true, notice: i18n_t('removed') }
  end
end
