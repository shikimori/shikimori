# 10.downto(0) {|v| TokyoToshokanParser.grab_page "http://www.tokyotosho.info/?page=#{v}&cat=0" }
class ImportToshokanTorrents
  include Sidekiq::Worker
  sidekiq_options(
    queue: :torrents_parsers,
    retru: false
  )

  PAGES = 7
  PAGE_URL = 'http://www.tokyotosho.info/?page=%s&cat=0'

  def perform is_rss
    if is_rss
      import_rss
    else
      0.upto(PAGES) { |page| import_web page }
    end
  end

private

  def import_rss
    RedisMutex.with_lock('import_toshokan_torrents', block: 0) do
      TokyoToshokanParser.grab_ongoings
    end
  rescue RedisMutex::LockError
  end

  def import_web page
    Retryable.retryable tries: 2, on: EmptyContentError, sleep: 10 do
      TokyoToshokanParser.grab_page PAGE_URL % page
    end
  end
end
