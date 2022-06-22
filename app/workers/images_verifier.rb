class ImagesVerifier
  include Sidekiq::Worker
  sidekiq_options(
    lock: :until_executed,
    queue: :slow_parsers,
    retry: false
  )

  def perform
    Anime.find_each { |entry| check_image entry }
    Manga.find_each { |entry| check_image entry }
    Character.find_each { |entry| check_image entry }
    Person.find_each { |entry| check_image entry }
  end

  def check_image entry
    return if !entry.image.exists? || ImageChecker.valid?(entry.image.path)

    NamedLogger.images_verifier.info "#{entry.class.name.downcase} #{entry.to_param}"
    puts "reloading #{entry.class.name.downcase} #{entry.to_param} image..."
    ImageReloader.call entry

  rescue EmptyContentError, NoMethodError
    puts "empty content for #{entry.class.name.downcase} #{entry.to_param}"
  end
end
