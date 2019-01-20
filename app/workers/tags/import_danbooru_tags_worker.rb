class Tags::ImportDanbooruTagsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    Tags::ImportDanbooruTags.call
    Tags::MatchDanbooruTags.call
  end
end
