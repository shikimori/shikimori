class UserTokensController < ShikimoriController
  load_and_authorize_resource

  def destroy
    if @resource.unlink_forbidden?
      flash[:alert] = i18n_t 'failure', auth_methods: missing_auth_methods
    else
      @resource.destroy
      flash[:notice] = i18n_t 'success', type: @resource.provider.titleize
    end

    redirect_to edit_profile_url(@resource.user, section: 'account')
  end

private

  def missing_auth_methods
    if missing_fields.many?
      i18n_t :email_password
    else
      i18n_t missing_fields.first
    end
  end

  def missing_fields
    [
      (:email if @resource.user.email.blank? ||
        @resource.user.email =~ /^generated_/),
      (:password if @resource.user.encrypted_password.blank?)
    ].compact
  end
end
