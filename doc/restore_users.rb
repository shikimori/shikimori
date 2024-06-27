json = JSON.parse(File.open('/tmp/z.json', 'r').read, symbolize_names: true);

User.transaction do
  ap "Users"
  json.each do |data|
    User.import([User.new(data[:user])], validate: false)

    user = User.find data[:user][:id]
    puts "User##{user.id}"
    user.style = Style.new(data[:style])
    user.preferences = UserPreferences.new(data[:user_preferences])
    user.save!
  end

  ap "Clubs"
  json.each do |data|
    data[:clubs_owned].each do |club_data|
      Club.import([Club.new(club_data[:club])], validate: false)
      club = Club.find club_data[:club][:id]
      puts "Club##{club.id}"
      club.style = Style.new(club_data[:style])
      club.save!

      {
        member_roles: ClubRole,
        pages: ClubPage,
        pages_topics: Topic,
        pages_topics_comments: Comment,
        links: ClubLink,
        bans: ClubBan,
        topics: Topic,
        topics_comments: Comment
      }.each do |key, klass|
        ap key
        result = klass.import(club_data[key].map { |v| klass.new v }, on_duplicate_key_ignore: true, validate: false)
        if result.failed_instances.any?
          ap result
          1/0
        end
      end
    end
  end

  ap "Collections"
  json.each do |data|
    data[:collections].each do |collection_data|
      Collection.import([Collection.new(collection_data[:collection])], validate: false)
      collection = Collection.find collection_data[:collection][:id]
      puts "Collection##{collection.id}"

      {
        links: CollectionLink,
        topics: Topic,
        topics_comments: Comment
      }.each do |key, klass|
        ap key
        result = klass.import(collection_data[key].map { |v| klass.new v }, on_duplicate_key_ignore: true, validate: false)
        if result.failed_instances.any?
          ap result
          1/0
        end
      end
    end
  end

  json.each do |data|
    {
      topics: Topic,
      comments: Comment
    }.each do |key, klass|
      result = klass.import(data[key].map { |v| klass.new v }, on_duplicate_key_ignore: true, validate: false)
      if result.failed_instances.any?
        ap result
        1/0
      end
    end
  end

  ap "Relations"
  json.each do |data|
    {
      oauth_applications: OauthApplication,
      access_grants: Doorkeeper::AccessGrant,
      user_tokens: UserToken,
      achievements: Achievement,
      anime_rates: UserRate,
      manga_rates: UserRate,
      user_rate_logs: UserRateLog,
      history: UserHistory,
      favourites: Favourite,
      ignores: Ignore,
      topic_ignores: TopicIgnore,
      nickname_changes: UserNicknameChange,
      polls: Poll,
      profile_comments: Comment,
      user_images: UserImage,
      messages: Message,
      versions: Version,
      collection_roles: CollectionRole,
      topic_viewings: TopicViewing,
      comment_viewings: CommentViewing,
      club_roles: ClubRole,
      friend_links: FriendLink
    }.each do |key, klass|
      ap key
      result = klass.import(data[key].map { |v| klass.new v }, on_duplicate_key_ignore: true, validate: false)
      if result.failed_instances.any?
        ap result
        1/0
      end
    end

    data[:abuse_requests].each do |v|
      abuse_request = AbuseRequest.new v
      abuse_request.save if abuse_request.topic || abuse_request.comment
    end
    ActsAsVotable::Vote.import(data[:'acts_as_votable/vote'].map { |v| ActsAsVotable::Vote.new v }, on_duplicate_key_ignore: true)
  end

  json.each do |data|
    data[:bans].each do |ban_data|
      ban = Ban.new({ **ban_data, duration: ban_data[:duration][:value] })
      ban.abuse_request_id = nil if ban.abuse_request.nil?
      ban.save!
    end
  end

  ap "Done"
end;
