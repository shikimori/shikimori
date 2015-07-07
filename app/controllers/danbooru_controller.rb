class DanbooruController < ShikimoriController
  respond_to :json, only: [:autocomplete, :yandere]

  UserAgentWithSSL = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36',
    ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }

  # если картинка уже есть, то редиректим на s3, иначе загружаем и отдаём картинку. а загрузку шедалим через delayed_jobs
  def autocomplete
    @items = DanbooruTagsQuery.new(params).complete
  end

  def yandere
    url = Base64.decode64(URI.decode params[:url])

    raise Forbidden, url unless url =~ /https?:\/\/yande.re/
    json = Rails.cache.fetch "yandere_#{url}", expires_in: 2.weeks do
      open(url, UserAgentWithSSL).read
    end

    render json: json

  rescue Timeout::Error, Net::ReadTimeout, OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Errno::ECONNREFUSED, OpenURI::HTTPError
    @retries ||= 2
    @retries -= 1

    if @retries > 0
      retry
    else
      raise
    end
  end

  class << self
    # путь к картинке на s3
    def s3_path(md5)
      "http://d.shikimori.org/#{md5}"
    end

    # путь к картинке на s3
    def filename(md5)
      "#{md5}.jpg"
    end
  end
end
