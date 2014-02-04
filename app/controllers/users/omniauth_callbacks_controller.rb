class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :set_omniauth_data

  def twitter
    omniauthorize_additional_account || omniauth_sign_in || omniauth_sign_up
  end

  def vkontakte
    omniauthorize_additional_account || omniauth_sign_in || omniauth_sign_up
  end

  def facebook
    omniauthorize_additional_account || omniauth_sign_in || omniauth_sign_up
  end

private
  def omniauthorize_additional_account
    return false unless user_signed_in?

    if @preexisting_token && @preexisting_token != current_user
      flash[:alert] = "Выбранный %s аккаунт уже подключён к другому пользователю сайта" % @omni.provider.titleize
    else
      OmniauthService.new(current_user, @omni).populate
      current_user.apply_omniauth(@omni)
      current_user.save

      flash[:notice] = "Подключена авторизация через %s" % @omni.provider.titleize
    end
    redirect_to user_settings_url(current_user)
  end

  def omniauth_sign_in
    return false unless @preexisting_token && @preexisting_token.user

    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: @omni.provider.titleize
    @preexisting_token.user.remember_me = true
    sign_in_and_redirect(:user, @preexisting_token.user)
    true
  end

  def omniauth_sign_up
    user = User.new
    OmniauthService.new(user, @omni).populate

    if @omni.provider == 'yandex' || @omni.provider == 'google_apps'
      redirect_to :disabled_registration
      return
    end

    user.save
    unless user.errors.empty?
      nickname = user.nickname
      email = user.email
      (2..100).each do |i|
        user.nickname = "#{nickname}#{i}" if user.errors.include?(:nickname)
        user.email = email.sub('@', "+#{i}@") if user.errors.include?(:email)
        break if user.save
      end
    end

    flash[:notice] = I18n.t "devise.omniauth_callbacks.register", kind: @omni.provider.titleize
    user.remember_me = true
    sign_in_and_redirect :user, user
  end

  def set_omniauth_data
    @omni = env["omniauth.auth"]

    if @omni.nil?
      flash[:alert] = 'Не удалось авторизоваться'

      if user_signed_in?
        redirect_to user_settings_url(current_user)
      else
        redirect_to :root
      end
      false
    else
      @preexisting_token = UserToken.find_by provider: @omni.provider, uid: @omni.uid
    end

  end
end
