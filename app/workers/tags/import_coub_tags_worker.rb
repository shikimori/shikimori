class Tags::ImportCoubTagsWorker
  include Sidekiq::Worker

  def perform
    tags = Tags::ImportCoubTags.call
    Tags::MatchCoubTags.call tags
  end
end
