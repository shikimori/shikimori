describe ProfileStatsQuery do
  let(:user) { create :user }
  let(:anime) { create :anime, episodes: 24, duration: 60 }
  let(:manga) { create :manga, chapters: 54 }

  subject(:stats) { ProfileStatsQuery.new user }

  describe '#to_hash' do
    it { expect(stats.to_hash).to have(18).items }
  end

  describe '#spent_time' do
    context 'watching' do
      let!(:anime_rate) { create :user_rate, :watching, user: user, anime: anime, episodes: 12 }
      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(0.5)
        expect(stats.manga_spent_time).to eq SpentTime.new(0)
        expect(stats.spent_time).to eq SpentTime.new(0.5)
      end
    end

    context 'completed' do
      let!(:anime_rate) { create :user_rate, :completed, user: user, anime: anime }
      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(1)
        expect(stats.manga_spent_time).to eq SpentTime.new(0)
        expect(stats.spent_time).to eq SpentTime.new(1)
      end
    end

    context 'completed & rewatched' do
      let!(:anime_rate) { create :user_rate, :completed, user: user, anime: anime, rewatches: 2 }

      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(3)
        expect(stats.manga_spent_time).to eq SpentTime.new(0)
        expect(stats.spent_time).to eq SpentTime.new(3)
      end
    end

    context 'with manga' do
      let!(:anime_rate) { create :user_rate, :completed, user: user, target: anime }
      let!(:manga_rate) { create :user_rate, :completed, user: user, target: manga }

      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(1.0)
        expect(stats.manga_spent_time).to eq SpentTime.new(0.3)
        expect(stats.spent_time).to eq SpentTime.new(1.3)
      end
    end
  end

  describe '#comments_count' do
    let(:topic) { create :topic, user: user }
    let!(:comment) { create_list :comment, 2, user: user, commentable: topic }
    let!(:comment_2) { create :comment, commentable: topic }
    subject { stats.comments_count }

    it { should eq 2 }
  end

  describe '#comments_reviews_count' do
    let(:topic) { create :topic, user: user }
    let!(:comment) { create :comment, :review, user: user, commentable: topic }
    let!(:comment_2) { create :comment, user: user, commentable: topic }
    subject { stats.comments_reviews_count }

    it { should eq 1 }
  end

  describe '#reviews_count' do
    let!(:review) { create :review, user: user }
    let!(:review_2) { create :review }
    subject { stats.reviews_count }

    it { should eq 1 }
  end

  describe '#content_changes_count' do
    let!(:version_1) { create :version, user: user, item: anime, state: :taken }
    let!(:version_2) { create :version, user: user, item: anime, state: :accepted }
    let!(:version_3) { create :version, user: user, item: anime, state: :pending }
    let!(:version_4) { create :version, user: user, item: anime, state: :rejected }
    let!(:version_5) { create :version, user: user, item: anime, state: :deleted }
    let!(:version_6) { create :version, item: anime, state: :taken }
    subject { stats.versions_count }

    it { should eq 2 }
  end

  describe '#videos_changes_count' do
    let!(:report_1) { create :anime_video_report, user: user, state: 'accepted' }
    let!(:report_2) { create :anime_video_report, user: user, state: 'rejected' }
    let!(:report_3) { create :anime_video_report, state: 'accepted' }
    subject { stats.videos_changes_count }

    it { should eq 1 }
  end
end
