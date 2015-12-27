class TopicIgnoresController < ShikimoriController
  load_and_authorize_resource

  def create
    # if @resource.save
      # render json: { notice: i18n_t('ignored') }
    # else
      # render json: @resource.errors.full_messages, status: :unprocessable_entity
    # end
  end

  def destroy
  end


private

  # def create_params
    # params.require(:club_invite).permit([:club_id, :src_id, :dst_id])
  # end
end
