# frozen_string_literal: true

shared_context :chewy_indexes do |indexes|
  include_context :timecop, 'Thu, 10 May 2018 09:00:00 PDT -07:00'

  before do
    if (%i[anime] & Array(indexes)).any?
      ActiveRecord::Base.connection.reset_pk_sequence! :animes
      AnimesIndex.purge!
      LicensorsIndex.purge!
    elsif (%i[manga] & Array(indexes)).any?
      ActiveRecord::Base.connection.reset_pk_sequence! :mangas
      MangasIndex.purge!
      LicensorsIndex.purge!
    elsif (%i[ranobe] & Array(indexes)).any?
      ActiveRecord::Base.connection.reset_pk_sequence! :mangas
      RanobeIndex.purge!
      LicensorsIndex.purge!
    elsif (%i[licensors] & Array(indexes)).any?
      LicensorsIndex.purge!
    else
      Array(indexes).each do |index|
        ActiveRecord::Base.connection.reset_pk_sequence! index
        "#{index.to_s.camelize}Index".constantize.purge!
      end
    end
  end
end
