class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :set_omniauth_data

  EXCEPTIONS = [ActiveRecord::RecordNotUnique, PG::UniqueViolation]

  def authorize
    Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
      omniauthorize_additional_account || omniauth_sign_in || omniauth_sign_up
    end
  end
  alias_method :twitter, :authorize
  alias_method :vkontakte, :authorize
  alias_method :facebook, :authorize

private

  def omniauthorize_additional_account
    return false unless user_signed_in?

    if @preexisting_token && @preexisting_token != current_user
      flash[:alert] = "Выбранный %s аккаунт уже подключён к другому пользователю сайта" % omniauth_data.provider.titleize
    else
      OmniauthService.new(current_user, omniauth_data).populate
      current_user.save

      flash[:notice] = "Подключена авторизация через %s" % omniauth_data.provider.titleize
    end
    redirect_to edit_profile_url current_user
  end

  def omniauth_sign_in
    return false unless @preexisting_token && @preexisting_token.user
    @resource = @preexisting_token.user

    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: omniauth_data.provider.titleize
    @resource.remember_me = true
    sign_in_and_redirect :user, @resource
    true
  end

  def omniauth_sign_up
    @resource = User.new
    OmniauthService.new(@resource, omniauth_data).populate

    if omniauth_data.provider == 'yandex' || omniauth_data.provider == 'google_apps'
      redirect_to :disabled_registration
      return
    end

    unless safe_save @resource
      nickname = @resource.nickname
      email = @resource.email

      (2..100).each do |i|
        if @resource.errors.include? :nickname
          @resource.nickname = "#{nickname}#{i}"
        end

        if @resource.errors.include? :email
          @resource.email = email.sub '@', "+#{i}@"
        end

        break if safe_save @resource
      end
    end

    flash[:notice] = I18n.t 'devise.omniauth_callbacks.register',
      kind: omniauth_data.provider.titleize

    @resource.remember_me = true
    sign_in_and_redirect :user, @resource
  end

  def set_omniauth_data
    @omni = env['omniauth.auth']

    if @omni.nil?
      flash[:alert] = 'Не удалось авторизоваться'

      if user_signed_in?
        redirect_to edit_profile_url(current_user)
      else
        redirect_to :root
      end
      false
    else
      @preexisting_token = UserToken.find_by(
        provider: @omni.provider,
        uid: @omni.uid
      )
    end
  end

  def omniauth_data
    @omni
  end

  def safe_save user
    @resource.save

  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    false
  end
end
