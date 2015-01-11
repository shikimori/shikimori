class ImagesVerifier
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  queue: :slow_parsers,
                  retry: false

  def perform
    Anime.find_each {|v| check_image v }
    Manga.find_each {|v| check_image v }
    Character.find_each {|v| check_image v }
    Person.find_each {|v| check_image v }
  end

  def check_image entry
    return if !entry.image.exists? || ImageChecker.valid?(entry.image.path)

    #NamedLogger.images_verifier.info "#{entry.class.name.downcase} #{entry.to_param}"
    puts "reloading #{entry.class.name.downcase} #{entry.to_param} image..."
    ImageReloader.new(entry).perform
  end
end
