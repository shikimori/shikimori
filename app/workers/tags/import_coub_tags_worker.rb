class Tags::ImportCoubTagsWorker
  include Sidekiq::Worker

  def perform
    match_tags import_tags
  end

private

  def import_tags
    Tags::ImportCoubTags.call
  end

  def match_tags tags
    Tags::MatchCoubTags.call tags
  end
end
