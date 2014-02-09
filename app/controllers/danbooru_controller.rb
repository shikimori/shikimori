class DanbooruController < ApplicationController
  respond_to :json, only: [:autocomplete, :yandere]

  UserAgent = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36' }
  TmpImagesDir = 'danbooru_tmp'

  # если картинка уже есть, то редиректим на s3, иначе загружаем и отдаём картинку. а загрузку шедалим через delayed_jobs
  def show
    url = Base64.decode64(params[:url])
    md5 = self.class.filename(params[:md5])

    raise Forbidden unless url =~ /https?:\/\/([^.]+.(donmai.us|imouto.org)|konachan.com|(\w+\.)?yande.re)/

    s3 = $redis.get(md5)
    redirect_to self.class.s3_path(md5) and return if s3

    filename = Rails.root.join('public', 'images', TmpImagesDir, md5)
    unless File.exists?(filename)
      data = open(url, UserAgent).read
      File.open(filename, 'wb') {|h| h.write(data) }
      #Delayed::Job.enqueue DanbooruJob.new(md5, url, filename) unless Rails.env == 'test'
    end
    redirect_to "/images/#{TmpImagesDir}/#{md5}"

  rescue OpenURI::HTTPError, URI::InvalidURIError
    raise NotFound, url

  rescue Timeout::Error, Net::ReadTimeout, OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Errno::ECONNREFUSED
    @retries ||= 2
    @retries -= 1

    if @retries > 0
      retry
    else
      raise
    end
  end

  def autocomplete
    @items = DanbooruTagsQuery.new(params).complete
  end

  def yandere
    url = Base64.decode64(params[:url])

    raise Forbidden unless url =~ /https?:\/\/yande.re/
    json = Rails.cache.fetch "yandere_#{url}", expires_in: 2.weeks do
      open(url, UserAgent).read
    end

    render json: json

  rescue Timeout::Error, Net::ReadTimeout, OpenSSL::SSL::SSLError, Errno::ETIMEDOUT, Errno::ECONNREFUSED
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
