class UserTokensController < ShikimoriController
  load_and_authorize_resource

  def destroy
    if @resource.unlink_forbidden?
      missed = [@resource.user.email =~ /^generated_/ ? 'e-mail' : nil, @resource.user.encrypted_password.blank? ? 'пароль' : nil].compact
      flash[:alert] = "Вы не сможете отключить единственный способ авторизации, пока не зададите #{missed.join(' и ')}."
      redirect_to :back and return
    end

    @resource.destroy

    flash[:notice] = "Отключена авторизация через #{@resource.provider.titleize}"
    redirect_to edit_profile_url(@resource.user)
  end
end
