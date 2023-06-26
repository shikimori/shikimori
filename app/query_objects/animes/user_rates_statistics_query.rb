class Animes::UserRatesStatisticsQuery
  pattr_initialize :entry, :user

  def friend_rates # rubocop:disable Metrics/MethodLength
    @entry.rates
      .where(user_id: @user.friend_links.select(:dst_id))
      .joins(user: [:preferences])
      .where(user_preferences: { list_privacy: %i[public users friends] })
      .joins(
        <<-SQL.squish
          left join friend_links
            on friend_links.src_id = users.id
            and friend_links.dst_id = #{@user.id}
        SQL
      )
      .where(
        'friend_links.id is not null or user_preferences.list_privacy in (?)',
        %i[public users]
      )
      .sort_by(&:updated_at)
      .reverse
  end
end
