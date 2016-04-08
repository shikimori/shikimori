# 10.downto(0) {|v| TokyoToshokanParser.grab_page "http://www.tokyotosho.info/?page=#{v}&cat=0" }
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
