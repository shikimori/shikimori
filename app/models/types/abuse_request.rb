module Types
  module AbuseRequest
    KINDS = %i[
      offtopic
      summary
      convert_review
      spoiler
      abuse
    ]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:pending, :accepted, :rejected)
  end
end
