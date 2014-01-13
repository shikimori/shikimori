class ToshokanTorrentsImporter
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    TokyoToshokanParser.grab_ongoings
  end
end
