class AdminLogInController < ShikimoriController
  # выход под любым пользователем для администратора
  def log_in
    if !Rails.env.production? || (user_signed_in? && current_user.admin?)
      @user = if params[:nickname] =~ /\A\d+\Z/
        User.find params[:nickname].to_i
      else
        User.where(nickname: params[:nickname]).first
      end

      if @user
        id = user_signed_in? ? current_user.id : nil
        # авторизоваться надо до задания сессии, а то она сбрасывается
        sign_in(@user)
        session[AdminLogInController.admin_id_to_restore_key] = id if id

        redirect_to :root
      else
        render text: "пользователь с ником на \"#{params[:nickname]}\" не найден", status: :unprocessable_entity
      end
    else
      render 'pages/page404.html', layout: set_layout, status: 404
    end
  end

  # восстановление авторизации администратора
  def restore
    if session[AdminLogInController.admin_id_to_restore_key].present?
      @user = User.find(session[AdminLogInController.admin_id_to_restore_key])
      session.delete AdminLogInController.admin_id_to_restore_key

      sign_in_and_redirect(@user)
    else
      render 'pages/page404.html', layout: set_layout, status: 404
    end
  end

  # имя куки с авторизацией админа
  def self.admin_id_to_restore_key
    'devise.admin_id_to_restore'
  end
end
