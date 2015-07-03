class AnimeStatusQuery
  pattr_initialize :relation

  LATEST_INTERVAL = 3.month

  def by_status status
    case status.to_sym
      when :anons, :ongoing, :released
        relation.where(status: status.to_sym)

      # TODO: remove
      when :planned
        relation.where(status: :anons)

      when :latest
        relation
          .where(status: :released)
          .where('released_on > ?', LATEST_INTERVAL.ago)

      else
        raise ArgumentError
    end
  end
end
