class Tags::ImportCoubTagsWorker
  include Sidekiq::Worker

  def perform
    Tags::CleanupIgnoredCoubTags.call

    Tags::ImportCoubTags.call do |tags|
      Tags::MatchCoubTags.call tags
    end
  end
end
