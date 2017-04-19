# 10.downto(0) {|v| TokyoToshokanParser.grab_page "http://www.tokyotosho.info/?page=#{v}&cat=0" }
class ImportToshokanTorrents
  include Sidekiq::Worker
  sidekiq_options(
    queue: :torrents_parsers,
    retru: false
  )

  def perform
    RedisMutex.with_lock('import_toshokan_torrents', block: 0) { import }
  rescue RedisMutex::LockError
  end

private

  def import
    TokyoToshokanParser.grab_ongoings

    2.downto(0) do |page|
      TokyoToshokanParser.grab_page(
        "http://www.tokyotosho.info/?page=#{page}&cat=0"
      )
    end
  rescue EmptyContentError
  end
end
