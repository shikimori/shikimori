class Tags::ImportCoubTagsWorker
  include Sidekiq::Worker

  def perform
    Tags::CleanupIgnoredCoubTags.call

    CoubTag.transaction do
      tags = Tags::FetchCoubTags.call
      Tags::MatchCoubTags.call tags
      Tags::ImportCoubTags.call tags
    end
  end
end
