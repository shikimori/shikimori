class NyaaTorrentsImporter
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :torrents_parsers
  )

  def perform
    NyaaParser.grab_ongoings
  end
end
