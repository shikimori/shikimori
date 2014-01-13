class NyaaTorrentsImporter
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    NyaaParser.grab_ongoings
  end
end
