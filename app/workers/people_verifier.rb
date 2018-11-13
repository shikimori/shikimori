class PeopleVerifier
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    PersonMalParser.import bad_entries if bad_entries.any?
    raise "Broken people found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Person.where(name: nil).pluck :id
  end
end
