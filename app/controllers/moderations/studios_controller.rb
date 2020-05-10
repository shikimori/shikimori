class Moderations::StudiosController < Moderations::GenresController
  SORTING_FIELD = :id

private

  def update_params
    params
      .require(:studio)
      .permit(:name, :image, :is_publisher, :is_verified, desynced: [])
      .tap do |allowed_params|
        if allowed_params[:is_publisher].present?
          allowed_params[:is_publisher] = allowed_params[:is_publisher] != '0'
        end
        if allowed_params[:is_verified].present?
          allowed_params[:is_verified] = allowed_params[:is_verified] != '0'
        end
      end
  end
end
