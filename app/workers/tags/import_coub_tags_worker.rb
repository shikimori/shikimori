class Tags::ImportCoubTagsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    Tags::CleanupIgnoredCoubTags.call

    tags = Tags::FetchCoubTags.call
    Tags::MatchCoubTags.call tags
    Tags::ImportCoubTags.call tags
  end
end
