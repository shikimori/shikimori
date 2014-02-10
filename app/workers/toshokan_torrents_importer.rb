class ToshokanTorrentsImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  queue: :torrents_parsers

  def perform
    TokyoToshokanParser.grab_ongoings
  end
end
