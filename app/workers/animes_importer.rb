class AnimesImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    AnimeMalParser.import
  end
end
