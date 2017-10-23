class DailyCosplay
  include Sidekiq::Worker

  def perform
    galleries = CosplayGallery.without_topics.to_a

    sample_gallery = galleries.sample
    sample_gallery.generate_topics(Shikimori::DOMAIN_LOCALES)

    sample_gallery.topics.each do |topic|
      FayePublisher.new(User.first).publish topic, :created, []
    end
  end
end
