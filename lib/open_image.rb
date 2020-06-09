module Kernel
  def open_image url, options = {}
    io = OpenURI.open_uri(
      URI.encode(url),
      {
        **options,
        **Proxy.paid_proxy
      }
    )
    def io.original_filename
      base_uri.path.split('/').last
    end
    io.original_filename.blank? ? nil : io
  end
end
