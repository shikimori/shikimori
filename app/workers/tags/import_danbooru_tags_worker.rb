class Tags::ImportDanbooruTagsWorker
  include Sidekiq::Worker

  def perform
    Tags::ImportDanbooruTags.call
    Tags::MatchDanbooruTags.call
  end
end
