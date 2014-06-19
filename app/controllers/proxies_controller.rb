class ProxiesController < ShikimoriController
  def index
    @cache = Proxy.all

    render :text => @cache.compact.map {|v| "%s:%d" % [v.ip, v.port] }.join("\n"), :mime_type => Mime::Type.lookup("text/plain")
  end
end
