describe Topics::ForumQuery do
  subject do
    Topics::ForumQuery.call(
      scope: scope,
      forum: forum,
      user: user,
      is_censored_forbidden: is_censored_forbidden
    )
  end

  let(:scope) { Topics::Query.fetch locale, is_censored_forbidden }
  let(:forum) { nil }
  let(:is_censored_forbidden) { false }

  let(:locale) { :ru }

  let(:all_sticky_topics) do
    [
      offtopic_topic,
      site_rules_topic,
      description_of_genres_topic,
      ideas_and_suggestions_topic,
      site_problems_topic,
      contests_proposals_topic,
      socials_topic
    ]
  end

  let!(:anime_topic) do
    create :topic,
      forum: animanga_forum,
      updated_at: 1.day.ago
  end
  let!(:critique) { create :critique, :with_topics, updated_at: 10.days.ago }
  let!(:joined_club) do
    create :club, :with_topics,
      updated_at: 15.days.ago,
      is_censored: true
  end
  let!(:joined_club_user_topic) do
    create :club_user_topic,
      linked: joined_club,
      forum_id: Topic::FORUM_IDS[ClubPage.name],
      created_at: 8.days.ago
  end
  let!(:joined_club_page) { create :club_page, club: joined_club }
  let!(:joined_club_page_topic) do
    create :club_page_topic,
      linked: joined_club_page,
      forum_id: Topic::FORUM_IDS[ClubPage.name],
      updated_at: 9.days.ago
  end
  let!(:another_club) do
    create :club, :with_topics,
      updated_at: 20.days.ago,
      is_censored: true
  end
  let!(:another_club_user_topic) do
    create :club_user_topic,
      linked: another_club,
      forum_id: Topic::FORUM_IDS[ClubPage.name],
      updated_at: 18.days.ago
  end
  let!(:another_club_page) { create :club_page, club: another_club }
  let!(:another_club_page_topic) do
    create :club_page_topic,
      linked: another_club_page,
      forum_id: Topic::FORUM_IDS[ClubPage.name],
      updated_at: 19.days.ago
  end
  # let!(:topic_ignore) {}

  before { joined_club.join user if user }

  context 'user defined forums' do
    before do
      user.preferences.forums = forums if user
      review.topic(locale).update_column :updated_at, review.updated_at
    end

    context 'no user' do
      let(:user) { nil }
      it do
        is_expected.to eq(
          [anime_topic] +
            all_sticky_topics +
            [review.topic(locale)]
        )
      end
    end

    context 'group of forums' do
      let(:forums) { [offtopic_forum.id, animanga_forum.id] }
      it { is_expected.to eq [anime_topic] + all_sticky_topics }

      # context 'topic_ignore' do
        # let!(:topic_ignore) { create :topic_ignore, user: user, topic: anime_topic }
        # it { is_expected.to eq [offtopic_topic, offtopic_topic] }
      # end
    end

    context 'my_clubs forum' do
      let(:forums) { [Forum::MY_CLUBS_FORUM.permalink] }
      it do
        is_expected.to eq [
          joined_club_user_topic,
          joined_club_page_topic,
          joined_club.topic(locale)
        ]
      end
    end

    context 'common forums' do
      let(:forums) { [animanga_forum.id] }
      it { is_expected.to eq [anime_topic] }
    end
  end

  context 'animanga/site/games/vn' do
    let(:forum) { animanga_forum }
    let!(:anime_news_topic) do
      create :news_topic,
        tags: [%w[аниме манга ранобэ].sample],
        updated_at: 2.days.ago
    end
    it { is_expected.to eq [anime_topic, anime_news_topic] }
  end

  context 'critiques' do
    let(:forum) { critiques_forum }
    it { is_expected.to eq [review.topic(locale)] }
  end

  context 'news' do
    let!(:generated_news_topic) { create :news_topic, :anime_anons }
    let!(:anime_news_topic) { create :news_topic, created_at: 1.day.ago }
    let!(:manga_news_topic) { create :news_topic, created_at: 2.days.ago }
    let!(:cosplay_news_topic) do
      create :cosplay_gallery_topic,
        created_at: 3.days.ago,
        linked: cosplay_gallery
    end
    let(:cosplay_gallery) { create :cosplay_gallery, :anime }
    let!(:contest_status_topic) do
      create :contest_status_topic, created_at: 4.days.ago
    end

    let(:forum) { Forum.news }

    it do
      is_expected.to eq [
        anime_news_topic,
        manga_news_topic,
        cosplay_news_topic,
        contest_status_topic
      ]
    end
  end

  context 'updates' do
    let!(:anime_news_topic) { create :news_topic, :anime_anons, created_at: 1.day.ago }
    let!(:regular_news) { create :news_topic }

    let(:forum) { Forum::UPDATES_FORUM }

    it { is_expected.to eq [anime_news_topic] }
  end

  context 'my_clubs' do
    let(:forum) { Forum::MY_CLUBS_FORUM }

    let!(:joined_club_2) { create :club, :with_topics, updated_at: 25.days.ago }
    before { joined_club_2.join user }

    it do
      is_expected.to eq [
        joined_club_user_topic,
        joined_club_page_topic,
        joined_club.topic(locale),
        joined_club_2.topic(locale)
      ]
    end
  end

  context 'clubs' do
    let!(:joined_club_2) { create :club, :with_topics, updated_at: 25.days.ago }
    let!(:other_club_2) { create :club, :with_topics, updated_at: 30.days.ago }

    let(:forum) { clubs_forum }

    context 'censored not forbidden' do
      let(:is_censored_forbidden) { false }
      it do
        is_expected.to eq [
          joined_club_user_topic,
          joined_club_page_topic,
          joined_club.topic(locale),
          another_club_user_topic,
          another_club_page_topic,
          another_club.topic(locale),
          joined_club_2.topic(locale),
          other_club_2.topic(locale)
        ]
      end
    end

    context 'censored forbidden' do
      let(:is_censored_forbidden) { true }
      it do
        is_expected.to eq [
          joined_club_user_topic,
          joined_club_page_topic,
          joined_club.topic(locale),
          joined_club_2.topic(locale),
          other_club_2.topic(locale)
        ]
      end
    end
  end

  context 'common forum' do
    let(:forum) { animanga_forum }
    it { is_expected.to eq [anime_topic] }
  end
end
