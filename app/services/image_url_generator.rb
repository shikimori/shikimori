class ImageUrlGenerator
  include Singleton

  IMAGE_METHODS = {
    User => :avatar,
    Club => :logo
  }
  ONLY_PATH = {
    UserImage => false
  }

  # TODO: remove fix for new.shikimori.org
  def url entry, image_size
    entry_method = IMAGE_METHODS.find { |klass, _method| entry.is_a? klass }
    only_path = ONLY_PATH.include?(entry.class) ? ONLY_PATH[entry.class] : true

    image_method = entry_method ? entry_method.second : :image
    image_index = entry.id % Shikimori::STATIC_SUBDOMAINS.size

    image_file_path = entry.send(image_method).path image_size
    image_url_path = entry.send(image_method).url image_size, only_path

    if Rails.env.production?
      "#{Shikimori::PROTOCOL}://" \
        "#{Shikimori::STATIC_SUBDOMAINS[image_index]}." \
        "#{Shikimori::DOMAIN}#{image_url_path}".gsub('new.shikimori', 'shikimori') # temporarily fix for new.shikimori.org
    elsif Rails.env.test? || (image_file_path && File.exist?(image_file_path))
      image_url_path
    else
      "#{Shikimori::PROTOCOL}://" \
        "#{Shikimori::STATIC_SUBDOMAINS[image_index]}." \
        "#{Shikimori::DOMAIN}#{image_url_path}".gsub('new.shikimori', 'shikimori') # temporarily fix for new.shikimori.org
    end
  end
end
