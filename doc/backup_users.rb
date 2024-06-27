# rubocop:disable Layout/LineLength
ids = [8, 419948, 1028805, 1105696, 1118835, 1172315, 1227283, 1383110, 1421200, 1422272, 1448249, 1469066, 1469728]; # rubocop:disable Style/NumericLiterals

File.open('/tmp/z.json', 'w') do |f|
  data = User.where(id: ids).each_with_object([]) do |user, memo|
    raise 'user.critiques' if user.critiques.any?
    raise 'user.reviews' if user.reviews.any?
    raise 'user.articles' if user.articles.any?

    # raise 'user.collections' if user.collections.any?

    memo.push({
      user: user.attributes,
      style: user.style,
      user_preferences: user.preferences,
      oauth_applications: user.oauth_applications.map(&:attributes),
      access_grants: user.access_grants.map(&:attributes),
      abuse_requests: user.abuse_requests,
      user_tokens: user.user_tokens,
      achievements: user.achievements,
      anime_rates: user.anime_rates,
      manga_rates: user.manga_rates,
      user_rate_logs: user.user_rate_logs,
      history: user.history,
      topic_viewings: user.topic_viewings,
      comment_viewings: user.comment_viewings,
      friend_links: user.friend_links,
      favourites: user.favourites,
      messages: user.messages,
      ignores: user.ignores,
      club_roles: user.club_roles,
      collections: user.collections.map do |collection|
        {
          collection:,
          links: collection.links,
          topics: [collection.topic],
          topics_comments: collection.topic.comments
        }
      end,
      collection_roles: user.collection_roles,
      versions: user.versions,
      topic_ignores: user.topic_ignores,
      nickname_changes: user.nickname_changes,
      bans: user.bans,
      polls: user.polls,
      'acts_as_votable/vote': (user.polls.flat_map(&:votes_for) + ActsAsVotable::Vote.where(voter: user.id)).uniq,
      profile_comments: Comment.where(commentable: user),
      user_images: user.user_images,
      clubs_owned: user.clubs_owned.map do |club|
        {
          club:,
          style: club.style,
          member_roles: user.clubs_owned.flat_map(&:member_roles),
          pages: user.clubs_owned.flat_map(&:pages),
          pages_topics: user.clubs_owned.flat_map(&:pages).map(&:topic),
          pages_topics_comments: user.clubs_owned.flat_map(&:pages).map(&:topic).flat_map(&:comments),
          links: user.clubs_owned.flat_map(&:links),
          bans: user.clubs_owned.flat_map(&:bans),
          topics: user.clubs_owned.flat_map(&:all_topics),
          topics_comments: user.clubs_owned.flat_map(&:all_topics).flat_map(&:comments)
        }
      end,
      topics: user.topics,
      comments: user.comments_all
    })
  end

  f.write(data.to_json)
end
# rubocop:enable Layout/LineLength
`scp /tmp/z.json shiki:/tmp/`
