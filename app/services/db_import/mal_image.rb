class DbImport::MalImage
  method_object :entry, :image_url

  PROXY_OPTIONS = {
    timeout: 30,
    validate_jpg: true,
    return_file: true,
    log: true
  }

  def call
    if @image_url.present? && image_policy.need_import?
      io = download_image
      @entry.image = io if io
    end
  rescue *Network::FaradayGet::NET_ERRORS
  end

private

  def image_policy
    DbImport::ImagePolicy.new @entry, @image_url
  end

  def no_image?
    @entry.new_record? || !@entry.image.exists?
  end

  def download_image
    io = mal_image
    io if io && io.original_filename.present?
  end

  def mal_image
    if (no_image? && @image_url !~ /\.jpe?g$/) || Rails.env.test?
      NamedLogger.proxy.info "GET #{@image_url}"
      OpenURI.open_image @image_url, 'User-Agent' => 'Mozilla/4.0 (compatible; ICS)'
    else
      Proxy.get @image_url, PROXY_OPTIONS
    end
  rescue RuntimeError => e
    raise unless /HTTP redirection loop/.match?(e.message)

    Proxy.get @image_url, PROXY_OPTIONS
  end
end
