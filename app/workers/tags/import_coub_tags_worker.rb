class Tags::ImportCoubTagsWorker
  include Sidekiq::Worker

  def perform
    Tags::CleanupIgnoredCoubTags.call

    tags = Tags::FetchCoubTags.call
    Tags::MatchCoubTags.call tags
    Tags::ImportCoubTags.call tags
  end
end
