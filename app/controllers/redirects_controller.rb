class RedirectsController < ShikimoriController
  def show
    NamedLogger.redirects.info(
      "#{params[:url]}\t#{Time.zone.now}\t#{request.remote_ip}\t#{current_user&.id}"
    )
    redirect_to params[:url].present? ? params[:url] : root_url
  end
end
