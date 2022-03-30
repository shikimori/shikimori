module OpenURI::OpenImage
  def open_image url, options = {}
    io = OpenURI.open_uri(
      URI.encode(url),
      (options[:proxy] ?
        options :
        { **Proxy.prepaid_proxy }.merge(options)
      )
    )
    def io.original_filename
      base_uri.path.split('/').last
    end
    io.original_filename.blank? ? nil : io
  end
end

OpenURI.send :extend, OpenURI::OpenImage
