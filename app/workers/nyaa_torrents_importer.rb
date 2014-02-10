class NyaaTorrentsImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  queue: :torrents_parsers

  def perform
    NyaaParser.grab_ongoings
  end
end
