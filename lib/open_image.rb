module Kernel
  def open_image url
    io = open URI.encode(url), 'User-Agent' => 'Mozilla/4.0 (compatible; ICS)'
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  end
end
