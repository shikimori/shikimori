# frozen_string_literal: true

class DbEntries::WithDescriptionQuery
  EMPTY_SOURCE = '%[source][/source]'

  class << self
    def with_description_ru_source relation
      relation.where("description_ru NOT LIKE '#{EMPTY_SOURCE}'")
    end
  end
end
