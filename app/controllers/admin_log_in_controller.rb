class AdminLogInController < ShikimoriController
  def log_in # rubocop:disable all
    if !Rails.env.production? || (user_signed_in? && current_user.admin?)
      @user =
        if /\A\d+\Z/.match?(params[:nickname])
          User.find params[:nickname].to_i
        else
          User.find_by(nickname: params[:nickname]) ||
            User.find_by(email: params[:nickname])
        end

      if @user
        id = user_signed_in? ? current_user.id : nil
        # авторизоваться надо до задания сессии, а то она сбрасывается
        sign_in(@user)
        session[AdminLogInController.admin_id_to_restore_key] = id if id

        redirect_to root_path
      else
        render(
          plain: "пользователь с ником на \"#{params[:nickname]}\" не найден",
          status: :unprocessable_entity
        )
      end
    else
      render 'pages/page404.html', layout: set_layout, status: :not_found
    end
  end

  def restore
    if session[AdminLogInController.admin_id_to_restore_key].present?
      @user = User.find(session[AdminLogInController.admin_id_to_restore_key])
      session.delete AdminLogInController.admin_id_to_restore_key

      sign_in_and_redirect @user
    else
      render 'pages/page404.html', layout: set_layout, status: :not_found
    end
  end

  def self.admin_id_to_restore_key
    'devise.admin_id_to_restore'
  end

private

  def devise_controller?
    true
  end
end
