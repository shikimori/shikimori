module Kernel
  def open_image url, *args
    io = open URI.encode(url), *args
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  end
end
