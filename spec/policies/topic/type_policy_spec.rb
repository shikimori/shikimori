describe Topic::TypePolicy do
  let(:policy) { described_class.new topic }

  let(:forum_topic) { build_stubbed :forum_topic }
  let(:news_topic) { build_stubbed :news_topic }
  let(:generated_news_topic) { build_stubbed :news_topic, generated: true }
  let(:not_generated_news_topic) { build_stubbed :news_topic, generated: false }
  let(:review_topic) { build_stubbed :review_topic }
  let(:cosplay_gallery_topic) { build_stubbed :cosplay_gallery_topic }
  let(:contest_topic) { build_stubbed :contest_topic }
  let(:club_topic) { build_stubbed :club_topic }
  let(:club_user_topic) { build_stubbed :club_user_topic }
  let(:club_page_topic) { build_stubbed :club_page_topic }
  let(:collection_topic) { build_stubbed :collection_topic, linked: collection }
  let(:article_topic) { build_stubbed :article_topic }

  let(:collection) { build_stubbed :collection, collection_state }
  let(:collection_state) { :published }

  describe '#forum_topic?' do
    subject { policy.forum_topic? }

    context 'forum topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq true }
    end

    context 'club_user_topic' do
      let(:topic) { club_user_topic }
      it { is_expected.to eq true }
    end

    context 'not forum topic' do
      let(:topic) { news_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#news_topic?' do
    subject { policy.news_topic? }

    context 'news topic' do
      let(:topic) { news_topic }
      it { is_expected.to eq true }
    end

    context 'not news topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#generated_news_topic?' do
    subject { policy.generated_news_topic? }

    context 'generated news topic' do
      let(:topic) { generated_news_topic }
      it { is_expected.to eq true }
    end

    context 'not generated news topic' do
      let(:topic) { news_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#not_generated_news_topic?' do
    subject { policy.not_generated_news_topic? }

    context 'not generated news topic' do
      let(:topic) { not_generated_news_topic }
      it { is_expected.to eq true }
    end

    context 'generated news topic' do
      let(:topic) { generated_news_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#review_topic?' do
    subject { policy.review_topic? }

    context 'review topic' do
      let(:topic) { review_topic }
      it { is_expected.to eq true }
    end

    context 'not review topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#cosplay_gallery_topic?' do
    subject { policy.cosplay_gallery_topic? }

    context 'cosplay gallery topic' do
      let(:topic) { cosplay_gallery_topic }
      it { is_expected.to eq true }
    end

    context 'not cospaly gallery topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#contest_topic?' do
    subject { policy.contest_topic? }

    context 'contest topic' do
      let(:topic) { contest_topic }
      it { is_expected.to eq true }
    end

    context 'not contest topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#club_topic?' do
    subject { policy.club_topic? }

    context 'club topic' do
      let(:topic) { club_topic }
      it { is_expected.to eq true }
    end

    context 'not club topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#club_user_topic?' do
    subject { policy.club_user_topic? }

    context 'club_user topic' do
      let(:topic) { club_user_topic }
      it { is_expected.to eq true }
    end

    context 'not club_user topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#club_page_topic?' do
    subject { policy.club_page_topic? }

    context 'club_page topic' do
      let(:topic) { club_page_topic }
      it { is_expected.to eq true }
    end

    context 'not club_page topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#any_club_topic?' do
    subject { policy.any_club_topic? }

    context 'club topic' do
      let(:topic) { club_topic }
      it { is_expected.to eq true }
    end

    context 'club_user topic' do
      let(:topic) { club_user_topic }
      it { is_expected.to eq true }
    end

    context 'club_page topic' do
      let(:topic) { club_page_topic }
      it { is_expected.to eq true }
    end

    context 'not contest topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#collection_topic?' do
    subject { policy.collection_topic? }

    context 'cosplay gallery topic' do
      let(:topic) { collection_topic }
      it { is_expected.to eq true }
    end

    context 'not cospaly gallery topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#article_topic?' do
    subject { policy.article_topic? }

    context 'cosplay gallery topic' do
      let(:topic) { article_topic }
      it { is_expected.to eq true }
    end

    context 'not cospaly gallery topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#commentable_topic?' do
    subject { policy.commentable_topic? }

    context 'collection_topic' do
      let(:topic) { collection_topic }

      context 'unpublished' do
        let(:collection_state) { :unpublished }
        it { is_expected.to eq false }
      end

      context 'published' do
        let(:collection_state) { :published }
        it { is_expected.to eq true }
      end

      context 'opened' do
        let(:collection_state) { :opened }
        it { is_expected.to eq true }
      end

      context 'private' do
        let(:collection_state) { :private }
        it { is_expected.to eq false }
      end
    end

    context 'other' do
      let(:topic) { forum_topic }
      it { is_expected.to eq true }
    end
  end

  describe '#votable_topic?' do
    subject { policy.votable_topic? }

    context 'review_topic' do
      let(:topic) { review_topic }
      it { is_expected.to eq true }
    end

    context 'cosplay_gallery_topic' do
      let(:topic) { cosplay_gallery_topic }
      it { is_expected.to eq true }
    end

    context 'collection_topic' do
      let(:topic) { collection_topic }

      context 'unpublished' do
        let(:collection_state) { :unpublished }
        it { is_expected.to eq false }
      end

      context 'published' do
        let(:collection_state) { :published }
        it { is_expected.to eq true }
      end

      context 'opened' do
        let(:collection_state) { :opened }
        it { is_expected.to eq true }
      end

      context 'private' do
        let(:collection_state) { :private }
        it { is_expected.to eq false }
      end
    end

    context 'other' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end
end
