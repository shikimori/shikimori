class Api::V1::NicknameChangesController < Api::V1Controller
  before_action do
    doorkeeper_authorize! :private if doorkeeper_token.present?
  end

  def cleanup
    current_user.nickname_changes.update_all is_deleted: true
    current_user.touch

    render json: { notice: i18n_t('cleared') }
  end
end
