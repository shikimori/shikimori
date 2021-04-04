class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :set_omniauth_data

  EXCEPTIONS = [
    ActiveRecord::RecordNotUnique,
    PG::UniqueViolation,
    RedisMutex::LockError
  ]

  def authorize
    Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
      RedisMutex.with_lock("#{@omni.provider}/#{@omni.uid}", block: 5) do
        @preexisting_token = UserToken.find_by(
          provider: @omni.provider,
          uid: @omni.uid
        )

        omniauthorize_additional_account || omniauth_sign_in || omniauth_sign_up
      end
    end
  end
  alias twitter authorize
  alias vkontakte authorize
  alias facebook authorize

private

  def omniauthorize_additional_account
    return false unless user_signed_in?

    provider = omniauth_data.provider.titleize
    if @preexisting_token && @preexisting_token != current_user
      flash[:alert] = i18n_t 'already_linked', provider: provider
    else
      Users::PopulateOmniauth.call current_user, omniauth_data
      current_user.save

      flash[:notice] = i18n_t 'account_linked', provider: provider
    end
    redirect_to edit_profile_url(current_user, section: 'account')
  end

  def omniauth_sign_in
    return false unless @preexisting_token&.user

    @resource = @preexisting_token.user

    flash[:notice] = I18n.t 'devise.omniauth_callbacks.success',
      kind: omniauth_data.provider.titleize

    # @resource.remember_me = true
    sign_in_and_redirect :user, @resource, event: :authentication

    true
  end

  def omniauth_sign_up # rubocop:disable all
    @resource = Users::PopulateOmniauth.call User.new, omniauth_data

    if omniauth_data.provider == 'yandex' || omniauth_data.provider == 'google_apps'
      return redirect_to disabled_registration_pages_url
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

    # @resource.remember_me = true
    sign_in_and_redirect :user, @resource, event: :authentication
  end

  def set_omniauth_data
    @omni = request.env['omniauth.auth']

    if @omni.nil?
      flash[:alert] = i18n_t 'authentication_failed'

      if user_signed_in?
        redirect_to edit_profile_url(current_user, section: 'account')
      else
        redirect_to root_url
      end
      false
    end
  end

  def omniauth_data
    @omni
  end

  def safe_save _user
    @resource.save
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    false
  end
end
