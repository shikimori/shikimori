class PeopleImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    PersonMalParser.import
  end
end
