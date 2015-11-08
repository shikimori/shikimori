class ToshokanTorrentsImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :torrents_parsers
  )

  def perform
    TokyoToshokanParser.grab_ongoings
  end
end
