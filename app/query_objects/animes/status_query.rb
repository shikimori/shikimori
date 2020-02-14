class Animes::StatusQuery
  method_object :scope, :status

  LATEST_INTERVAL = 3.month

  def call
    case Types::Anime::StatusExtended[@status]
      when :anons, :ongoing, :released
        @scope.where(status: @status.to_s)

      when :latest
        @scope
          .where(status: :released)
          .where('released_on > ?', LATEST_INTERVAL.ago)
    end
  rescue Dry::Types::ConstraintError
    raise InvalidParameterError.new(:status, @status)
  end
end
