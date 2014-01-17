class SakuhindbImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  unique_args: -> (args) { args },
                  retry: false

  def perform options
    parser = SakuhindbParser.new
    parser.fail_on_unmatched = options[:with_fail]
    parser.fetch_and_merge
  end
end
