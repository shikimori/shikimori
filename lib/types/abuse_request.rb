module Types
  module AbuseRequest
    KINDS = %i[
      offtopic
      summary
      review
      spoiler
      abuse
    ]

    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
