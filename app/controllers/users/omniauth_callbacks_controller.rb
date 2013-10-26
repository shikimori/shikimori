class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  attr_accessor :omniauth_data
  attr_accessor :preexisting_authorization_token

  before_filter :set_omniauth_data

  def method_missing(provider)
    return super unless valid_provider?(provider)
    omniauthorize_additional_account || omniauth_sign_in || omniauth_sign_up
  end

  def omniauthorize_additional_account
    return false unless user_signed_in?

    #todo signin not necessary, may mess up last sign in dates
    if preexisting_authorization_token && preexisting_authorization_token != current_user
      flash[:alert] = "Выбранный %s аккаунт уже подключён к другому пользователю сайта" % omniauth_data['provider'].titleize
    else
      current_user.apply_omniauth(omniauth_data)
      current_user.save

      flash[:notice] = "Подключена авторизация через %s" % omniauth_data['provider'].titleize
    end
    redirect_to user_settings_url(current_user)
  end

  def omniauth_sign_in
    #todo merge by email if signing in with a new account for which we already have a user (match on email)
    return false unless preexisting_authorization_token && preexisting_authorization_token.user

    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth_data['provider'].titleize
    preexisting_authorization_token.user.remember_me = true
    sign_in_and_redirect(:user, preexisting_authorization_token.user)
    true
  end

  def omniauth_sign_up
    #unless omniauth_data.recursive_find_by_key("email").blank?
      #user = User.find_or_initialize_by_email(:email => omniauth_data.recursive_find_by_key("email"))
    #else
      user = User.new
    #end

    user.apply_omniauth(omniauth_data)

    if omniauth_data['provider'] == 'yandex' || omniauth_data['provider'] == 'google_apps'
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

    #if user.save
      flash[:notice] = I18n.t "devise.omniauth_callbacks.register", :kind => omniauth_data['provider'].titleize
      user.remember_me = true
      sign_in_and_redirect(:user, user)
    #else
      #session[:omniauth] = omniauth_data.except('extra')
      #redirect_to new_user_registration_url
    #end
  end

  def set_omniauth_data
    self.omniauth_data = env["omniauth.auth"]
    if self.omniauth_data.nil?
      flash[:alert] = 'Не удалось авторизоваться'
      if user_signed_in?
        redirect_to user_settings_url(current_user)
      else
        redirect_to :root
      end
      return false
    end
    self.preexisting_authorization_token = UserToken.find_by_provider_and_uid(omniauth_data['provider'], omniauth_data['uid'])
  end

  def valid_provider?(provider)
    !User.omniauth_providers.index(provider).nil?
  end
end
