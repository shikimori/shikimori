class AnimesImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  queue: :slow_parsers,
                  retry: false

  def perform
    AnimeMalParser.import
  end
end
