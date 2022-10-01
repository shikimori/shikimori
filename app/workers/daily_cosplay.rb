class DailyCosplay
  include Sidekiq::Worker

  def perform
    galleries = CosplayGallery.without_topics.to_a

    sample_gallery = galleries.sample
    sample_gallery.generate_topic

    sample_gallery.topics.each do |topic|
      FayePublisher.new(User.first).publish topic, :created, []
    end
  end
end
