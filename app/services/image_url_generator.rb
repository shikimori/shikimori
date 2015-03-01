class ImageUrlGenerator
  include Singleton

  IMAGE_METHODS = {
    User => :avatar,
    Group => :logo
  }

  def url entry, image_size
    entry_method = IMAGE_METHODS.find {|klass,method| entry.kind_of? klass }

    image_method = entry_method ? entry_method.second : :image
    image_index = entry.id % Site::STATIC_SUBDOMAINS.size
    image_path = entry.send(image_method).url image_size

    if Rails.env.production?
      "http://#{Site::STATIC_SUBDOMAINS[image_index]}.#{Site::DOMAIN}#{image_path}"
    else
      image_path
    end
  end
end
