class MangasImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def do
    MangaMalParser.import
  end
end
