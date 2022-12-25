class DbImport::MalImage
  method_object %i[entry! image_url! proxy]

  PROXY_OPTIONS = {
    timeout: 30,
    validate_jpg: true,
    return_file: true,
    log: true
  }

  def call
    if @image_url.present? && policy.need_import?
      io = download_image
      @entry.image = io if io
    end
  rescue *::Network::FaradayGet::NET_ERRORS
  end

private

  def policy
    DbImport::ImagePolicy.new entry: @entry, image_url: @image_url
  end

  def no_image?
    @entry.new_record? || !@entry.image.exists?
  end

  def download_image
    io = mal_image
    io if io && io.original_filename.present?
  end

  def mal_image
    if skip_proxy?
      NamedLogger.proxy.info "GET #{@image_url}"
      OpenURI.open_image @image_url, 'User-Agent' => 'Mozilla/4.0 (compatible; ICS)'
    else
      Proxy.get @image_url, proxy_options
    end
  rescue RuntimeError => e
    raise unless /HTTP redirection loop/.match?(e.message)

    Proxy.get @image_url, PROXY_OPTIONS
  end

  def skip_proxy?
    !@proxy && (
      (no_image? && !@image_url.match?(/\.jpe?g$/)) ||
        Rails.env.test?
    )
  end

  def proxy_options
    @proxy ?
      {
        proxy: @proxy,
        **PROXY_OPTIONS
      } :
      PROXY_OPTIONS
  end
end
