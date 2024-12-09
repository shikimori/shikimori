class ImageUrlGenerator
  include Singleton

  IMAGE_METHODS = {
    User => :avatar,
    Club => :logo
  }
  USE_SUBDOMAINS = {
    User => false
  }
  ONLY_PATH = {
    UserImage => false
  }

  # SELECTED_STATIC_SUBDOMAINS = Shikimori::STATIC_PROXIED_SUBDOMAINS
  SELECTED_STATIC_SUBDOMAINS = Shikimori::STATIC_CLOUDFLARE_SUBDOMAINS +
    Shikimori::STATIC_PROXIED_SUBDOMAINS

  def cdn_image_url entry, image_size # rubocop:disable all
    image_method = IMAGE_METHODS
      .find { |klass, _method| entry.is_a? klass }
      &.second || :image
    is_only_path = ONLY_PATH.include?(entry.class) ?
      ONLY_PATH[entry.class] :
      true

    image_file_path = entry.send(image_method).path image_size
    image_url_path = entry.send(image_method).url image_size, is_only_path

    if Rails.env.test? ||
        (!Rails.env.production? && image_file_path && File.exist?(image_file_path))
      local_url image_url_path
    else
      image_index = entry.id % SELECTED_STATIC_SUBDOMAINS.size
      production_url(
        image_url_path,
        USE_SUBDOMAINS[entry.class] == false ? nil : image_index
      )
    end
  end

  def cdn_poster_url poster:, derivative: # rubocop:disable Metrics/AbcSize
    # image_index = poster.id % Shikimori::STATIC_CLOUDFLARE_SUBDOMAINS.size
    image_path = derivative && poster.image_data['derivatives'] ?
      poster.image(derivative).url :
      poster.image.url

    if Rails.env.test? ||
        (!Rails.env.production? && File.exist?(poster.image.storage.path(poster.image.id)))
      local_url image_path
    else
      image_index = poster.id % SELECTED_STATIC_SUBDOMAINS.size
      production_url(
        image_path,
        USE_SUBDOMAINS[Poster] == false ? nil : image_index
      )
    end

    # if Rails.env.development? && !File.exist?(poster.image.storage.path(poster.image.id))
    #   production_url image_path, image_index
    # else
    #   local_url image_path
    # end
  end

private

  def shiki_domain
    if Rails.env.test?
      Shikimori::DOMAINS[:test]
    elsif Rails.env.development? || ENV['USER'] == 'morr' ||
        (Draper::ViewContext.current.request.try(:host) ||
        Shikimori::DOMAINS[:test]) == Shikimori::DOMAINS[:test]
      Shikimori::DOMAINS[:production]
    else
      Url.new(Draper::ViewContext.current.request.host).cut_subdomain.to_s
    end

    # if Rails.env.test?
    #   'test.host'
    # elsif Rails.env.development? || ENV['USER'] == 'morr' ||
    #     (Draper::ViewContext.current.request.try(:host) || 'test.host') == 'test.host'
    #   Shikimori::DOMAINS[:production]
    # else
    #   Url.new(Draper::ViewContext.current.request.host).cut_subdomain.to_s
    # end
  end

  def production_url image_url_path, image_index
    "#{Shikimori::PROTOCOLS[:production]}://" +
      (image_index ? "#{SELECTED_STATIC_SUBDOMAINS[image_index]}." : '') +
      "#{shiki_domain}#{image_url_path}"
  end

  def local_url image_url_path
    image_url_path
  end
end
