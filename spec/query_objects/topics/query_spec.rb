describe Topics::Query do
  subject(:query) { Topics::Query.fetch user, locale }

  let(:locale) { :ru }
  let(:is_censored_forbidden) { false }

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

  describe '#result' do
    context 'domain matches topic locale' do
      it { is_expected.to eq all_sticky_topics }
    end

    context 'domain does not match topic locale' do
      let(:locale) { :en }
      it { is_expected.to be_empty }
    end
  end

  describe '#by_forum' do
    let!(:anime_topic) do
      create :topic,
        forum: animanga_forum,
        updated_at: 1.day.ago
    end
    let!(:review) { create :review, :with_topics, updated_at: 10.days.ago }
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
      subject { query.by_forum nil, user, is_censored_forbidden }

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

    context 'reviews' do
      subject { query.by_forum reviews_forum, user, is_censored_forbidden }
      it { is_expected.to eq [review.topic(locale)] }
    end

    context 'NEWS' do
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

      subject { query.by_forum Forum::NEWS_FORUM, user, is_censored_forbidden }

      it do
        is_expected.to eq [
          anime_news_topic,
          manga_news_topic,
          cosplay_news_topic,
          contest_status_topic
        ]
      end
    end

    context 'UPDATES' do
      let!(:anime_news_topic) { create :news_topic, :anime_anons, created_at: 1.day.ago }
      let!(:regular_news) { create :news_topic }
      subject { query.by_forum Forum::UPDATES_FORUM, user, is_censored_forbidden }

      it { is_expected.to eq [anime_news_topic] }
    end

    context 'MY_CLUBS' do
      subject { query.by_forum(Forum::MY_CLUBS_FORUM, user, is_censored_forbidden) }

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

      subject { query.by_forum clubs_forum, user, is_censored_forbidden }

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
      subject { query.by_forum animanga_forum, user, is_censored_forbidden }
      it { is_expected.to eq [anime_topic] }
    end
  end

  describe '#by_linked' do
    subject { query.by_linked linked }

    context 'not club' do
      let(:linked) { create :anime }
      let!(:topic_1) { create :topic, linked: linked }
      let!(:topic_2) { create :topic }
      it { is_expected.to eq [topic_1] }
    end

    context 'club' do
      let!(:linked) { create :club, :with_topics, is_censored: true }
      let!(:club_page) { create :club_page, club: linked }
      let!(:club_page_topic) do
        create :club_page_topic,
          linked: club_page,
          updated_at: 9.days.ago,
          comments_count: club_page_topic_comments_count
      end
      let!(:club_user_topic) do
        create :club_user_topic,
          linked: club_page,
          updated_at: 8.days.ago
      end

      context 'wo comments' do
        let(:club_page_topic_comments_count) { 0 }
        it { is_expected.to eq [club_user_topic] }
      end

      context 'with comments' do
        let(:club_page_topic_comments_count) { 1 }
        before do
          linked
            .topic(locale)
            .update_columns(comments_count: 1, updated_at: 15.days.ago)
        end

        it do
          is_expected.to eq [
            club_user_topic,
            club_page_topic,
            linked.topic(locale)
          ]
        end
      end
    end
  end

  describe '#search' do
    let!(:topic_1) { create :topic, id: 1 }
    let!(:topic_2) { create :topic, id: 2 }
    let!(:topic_3) { create :topic, id: 3 }
    let!(:topic_en) { create :topic, id: 4, locale: :en }

    subject { query.search phrase, forum, user, locale }

    let(:phrase) { 'test' }
    let(:forum) { seed :animanga_forum }
    let(:user) { nil }
    let(:locale) { 'ru' }
    let(:topics) { [topic_1, topic_2] }

    before do
      allow(Topics::SearchQuery).to receive(:call).with(
        scope: anything,
        phrase: phrase,
        forum: forum,
        user: user,
        locale: locale
      ).and_return(topics)
    end

    it { is_expected.to eq topics }
  end

  describe '#as_views' do
    let(:is_preview) { true }
    let(:is_mini) { true }

    subject(:views) { query.as_views(is_preview, is_mini) }

    it do
      expect(views).to have(7).items
      expect(views.first).to be_kind_of Topics::View
      expect(views.first.is_mini).to eq true
      expect(views.first.is_preview).to eq true
    end

    context 'preview' do
      let(:is_preview) { false }
      it do
        expect(views.first.is_mini).to eq true
        expect(views.first.is_preview).to eq false
      end
    end

    context 'mini' do
      let(:is_mini) { false }
      it do
        expect(views.first.is_mini).to eq false
        expect(views.first.is_preview).to eq true
      end
    end
  end
end
