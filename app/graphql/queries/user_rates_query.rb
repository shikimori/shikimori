class Queries::UserRatesQuery < Queries::BaseQuery
  type [Types::UserRateType], null: false

  LIMIT = 50
  PRELOADS = %i[anime manga]

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer,
    required: false,
    default_value: 2,
    description: "Maximum #{LIMIT}"
  argument :user_id, ID,
    required: false,
    description: 'ID of current user is used by default'
  argument :target_type, Types::Enums::UserRate::TargetTypeEnum, required: true
  argument :status, Types::Enums::UserRate::StatusEnum, required: false

  def resolve(
    page:,
    limit:,
    target_type:,
    user_id: current_user&.id,
    status: nil
  )
    return [] if user_id.blank?

    scope = QueryObjectBase.new(UserRate)
      .lazy_preload(*PRELOADS)
      .where(user_id:)
      .where(target_type:)
      .order(:id)

    scope = scope.where(status:) if status.present?
    scope
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
