class ImageUrlGenerator
  include Singleton

  IMAGE_METHODS = {
    User => :avatar,
    Club => :logo
  }
  ONLY_PATH = {
    UserImage => false
  }

  def cdn_image_url entry, image_size # rubocop:disable all
    image_method = IMAGE_METHODS
      .find { |klass, _method| entry.is_a? klass }
      &.second || :image
    only_path = ONLY_PATH.include?(entry.class) ? ONLY_PATH[entry.class] : true

    image_index = entry.id % Shikimori::STATIC_SUBDOMAINS.size

    image_file_path = entry.send(image_method).path image_size
    image_url_path = entry.send(image_method).url image_size, only_path

    if Rails.env.test? ||
        (!Rails.env.production? && image_file_path && File.exist?(image_file_path))
      local_url image_url_path
    else
      production_url image_url_path, image_index
    end
  end

  def cdn_poster_url db_entry:, poster:, derivative:
    image_index = db_entry.id % Shikimori::STATIC_SUBDOMAINS.size
    image_path = derivative ?
      poster.image(derivative).url :
      poster.image.url

    if Rails.env.test? || (!Rails.env.production? && File.exist?(Rails.public_path + image_path))
      local_url image_path
    else
      production_url image_path, image_index
    end
  end

private

  def shiki_domain
    if Rails.env.test?
      'test.host'
    elsif Rails.env.development? || ENV['USER'] == 'morr' ||
        (Draper::ViewContext.current.request.try(:host) || 'test.host') == 'test.host'
      Shikimori::DOMAINS[:production]
    else
      Url.new(Draper::ViewContext.current.request.host).cut_subdomain.to_s
    end
  end

  def production_url image_url_path, image_index
    "#{Shikimori::PROTOCOLS[:production]}://" \
      "#{Shikimori::STATIC_SUBDOMAINS[image_index]}." \
      "#{shiki_domain}#{image_url_path}"
  end

  def local_url image_url_path
    image_url_path
  end
end
