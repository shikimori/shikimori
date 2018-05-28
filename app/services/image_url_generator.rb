class ImageUrlGenerator
  include Singleton

  IMAGE_METHODS = {
    User => :avatar,
    Club => :logo
  }
  ONLY_PATH = {
    UserImage => false
  }

  def url entry, image_size
    entry_method = IMAGE_METHODS.find { |klass, _method| entry.is_a? klass }
    only_path = ONLY_PATH.include?(entry.class) ? ONLY_PATH[entry.class] : true

    image_method = entry_method ? entry_method.second : :image
    image_index = entry.id % Shikimori::STATIC_SUBDOMAINS.size

    image_file_path = entry.send(image_method).path image_size
    image_url_path = entry.send(image_method).url image_size, only_path

    if Rails.env.production?
      "#{Shikimori::PROTOCOLS[:production]}://" \
        "#{Shikimori::STATIC_SUBDOMAINS[image_index]}." \
        "#{Shikimori::DOMAINS[:production]}#{image_url_path}"
    elsif Rails.env.test? || (image_file_path && File.exist?(image_file_path))
      image_url_path
    else
      "#{Shikimori::PROTOCOLS[:production]}://" \
        "#{Shikimori::STATIC_SUBDOMAINS[image_index]}." \
        "#{Shikimori::DOMAINS[:production]}#{image_url_path}"
    end
  end
end
