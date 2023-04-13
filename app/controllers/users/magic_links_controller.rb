# based on https://github.com/abevoelker/devise-passwordless/blob/master/lib/devise/passwordless/login_token.rb

class Users::MagicLinksController < ShikimoriController
  def show
    user = User.find Users::LoginToken.decode(params[:token])['data']['user_id']
    sign_in user
    redirect_to redirect_url
  # rescue ActiveRecord::RecordNotFound, InvalidOrExpiredTokenError
  #   redirect_to redirect_url
  end

private

  def redirect_url
    params[:redirect_url].presence || root_url
  end
end
