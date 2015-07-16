class Api::V1::NicknameChangesController < Api::V1::ApiController
  def cleanup
    current_user.nickname_changes.destroy_all
    render json: { notice: "Ваша история имён очищена" }
  end
end
