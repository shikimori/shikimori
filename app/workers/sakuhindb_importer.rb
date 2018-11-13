class SakuhindbImporter
  include Sidekiq::Worker
  sidekiq_options dead: false
  sidekiq_retry_in { 60 * 60 * 24 }

  def perform options
    options = HashWithIndifferentAccess.new options

    parser = SakuhindbParser.new
    parser.fail_on_unmatched = options[:with_fail]
    parser.fetch_and_merge
  end
end
