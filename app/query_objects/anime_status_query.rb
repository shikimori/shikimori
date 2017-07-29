class AnimeStatusQuery
  pattr_initialize :relation

  LATEST_INTERVAL = 3.month

  def by_status status
    case Types::Anime::Status[status]
      when :anons, :ongoing, :released
        relation.where(status: status.to_s)

      when :latest
        relation
          .where(status: :released)
          .where('released_on > ?', LATEST_INTERVAL.ago)
    end
  end
end
