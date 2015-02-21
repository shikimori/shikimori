class DailyCosplay
  include Sidekiq::Worker

  def perform
    galleries = CosplayGallery.without_topic.to_a;
    CosplayComment.delete_all;
    1.times do
      topic = galleries.sample.send(:generate_thread)
      FayePublisher.new(User.first).publish topic, :created, []
    end;
  end
end
