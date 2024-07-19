class Queries::UserRatesQuery < Queries::BaseQuery
  type [Types::UserRateType], null: false

  LIMIT = 50
  PRELOADS = %i[anime manga]

  argument :page, Types::Scalars::PositiveInt, required: false, default_value: 1
  argument :limit, Types::Scalars::PositiveInt,
    required: false,
    default_value: 2,
    description: "Maximum #{LIMIT}"
  argument :user_id, ID,
    required: false,
    description: 'ID of current user is used by default'
  argument :target_type, Types::Enums::UserRate::TargetTypeEnum, required: false
  argument :status, Types::Enums::UserRate::StatusEnum, required: false
  argument :order, Types::Inputs::UserRate::OrderInputType, required: false

  def resolve( # rubocop:disable Metrics/ParameterLists
    page:,
    limit:,
    target_type: nil,
    user_id: current_user&.id,
    status: nil,
    order: nil
  )
    return [] if user_id.blank?

    scope = QueryObjectBase.new(UserRate)
      .lazy_preload(*PRELOADS)
      .where(user_id:)
      .order(order ? { order.field.to_sym => order.order.to_sym } : :id)

    scope = scope.where(target_type:) if target_type.present?
    scope = scope.where(status:) if status.present?

    scope
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
