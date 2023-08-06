class Queries::UserRatesQuery < Queries::BaseQuery
  type [Types::UserRateType], null: false

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer, required: false, default_value: 2
  argument :user_id, GraphQL::Types::BigInt, required: false
  argument :target_type, Types::Enums::UserRate::TargetTypeEnum, required: true
  argument :status, Types::Enums::UserRate::StatusEnum, required: false

  LIMIT = 50

  def resolve(
    page:,
    limit:,
    target_type:,
    user_id: current_user&.id,
    status: nil
  )
    return [] unless current_user

    scope = QueryObjectBase.new(UserRate)
      .where(user_id: user_id)
      .where(target_type: target_type)
      .order(:id)

    scope = scope.where(status: status) if status.present?
    scope
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
