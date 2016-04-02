class ImportToshokanTorrents
  include Sidekiq::Worker
  sidekiq_options queue: :torrents_parsers

  def perform
    RedisMutex.with_lock('import_toshokan_torrents', block: 0) do
      TokyoToshokanParser.grab_ongoings
    end
  rescue RedisMutex::LockError
  end
end
