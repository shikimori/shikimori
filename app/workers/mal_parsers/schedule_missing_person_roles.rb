class MalParsers::ScheduleMissingPersonRoles
  include Sidekiq::Worker
  sidekiq_options queue: :mal_parsers

  TYPES = Types::Coercible::String.enum('character', 'person')

  def perform type
    missing_ids(TYPES[type]).each do |id|
      MalParsers::FetchEntry.perform_async id, type
    end
  end

private

  def missing_ids type
    field = "#{type}_id"
    table_name = type.pluralize

    PersonRole
      .where.not(field => nil)
      .joins("left join #{table_name} on #{table_name}.id = #{field}")
      .where(table_name => { id: nil })
      .order(:id)
      .pluck(field)
      .uniq
  end
end
