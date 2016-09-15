describe TopicsQuery do
  include_context :seeds

  subject(:query) { TopicsQuery.fetch user, locale }

  let(:locale) { :ru }
  let(:is_censored_forbidden) { false }

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
    let!(:anime_topic) { create :topic, forum: animanga_forum, updated_at: 1.day.ago }
    let!(:review) { create :review, :with_topics, updated_at: 10.days.ago }
    let!(:joined_club) { create :club, :with_topics, updated_at: 15.days.ago, is_censored: true }
    let!(:another_club) { create :club, :with_topics, updated_at: 20.days.ago, is_censored: true }
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
        it { is_expected.to eq [joined_club.topic(locale)] }
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
          created_at: 3.days.ago, linked: cosplay_gallery
      end
      let(:cosplay_gallery) { create :cosplay_gallery, :anime }

      subject { query.by_forum Forum::NEWS_FORUM, user, is_censored_forbidden }

      it { is_expected.to eq [anime_news_topic, manga_news_topic, cosplay_news_topic] }
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

      it { is_expected.to eq [joined_club.topic(locale), joined_club_2.topic(locale)] }
    end

    context 'clubs' do
      let!(:joined_club_2) { create :club, :with_topics, updated_at: 25.days.ago }
      let!(:other_club_2) { create :club, :with_topics, updated_at: 30.days.ago }

      subject { query.by_forum clubs_forum, user, is_censored_forbidden }

      context 'censored not forbidden' do
        let(:is_censored_forbidden) { false }
        it do
          is_expected.to eq [
            joined_club.topic(locale),
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
    let(:linked) { create :anime }
    let!(:topic_1) { create :topic, linked: linked, forum: animanga_forum }
    let!(:topic_2) { create :topic, forum: animanga_forum }

    subject do
      query
        .by_forum(animanga_forum, user, is_censored_forbidden)
        .by_linked(linked)
    end

    it { is_expected.to eq [topic_1] }
  end

  describe '#as_views' do
    let(:is_preview) { true }
    let(:is_mini) { true }

    subject(:views) { query.as_views(is_preview, is_mini) }

    it do
      expect(views).to have(6).items
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
