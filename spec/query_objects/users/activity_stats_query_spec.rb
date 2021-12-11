describe Users::ActivityStatsQuery do
  subject(:stats) { described_class.new user }
  let(:anime) { create :anime }

  describe '#call' do
    it do
      expect(stats.call.to_h).to have(10).items
      expect(stats.call).to be_kind_of Users::ActivityStats
    end
  end

  describe '#comments_count' do
    let!(:comment_1) { create :comment, user: user }
    let!(:comment_2) { create :comment, user: user }
    let!(:comment_4) { create :comment, user: user_2 }

    its(:comments_count) { is_expected.to eq 2 }
  end

  describe '#reviews_count' do
    let!(:review_1) { create :review, user: user, anime: anime }
    let!(:review_2) { create :review, user: user, manga: manga }
    let!(:review_3) { create :review, user: user_2, anime: anime }

    let(:anime) { create :anime }
    let(:manga) { create :manga }

    its(:reviews_count) { is_expected.to eq 2 }
  end

  describe '#critiques_count' do
    let!(:critique_1) { create :critique, :accepted, user: user, approver: user }
    let!(:critique_2) { create :critique, :pending, user: user }
    let!(:critique_4) { create :critique, :rejected, user: user, approver: user }
    let!(:critique_5) { create :critique, user: user_2 }

    its(:critiques_count) { is_expected.to eq 2 }
  end

  describe '#collections_count' do
    let!(:collection_1) { create :collection, :accepted, :published, user: user, approver: user }
    let!(:collection_2) { create :collection, :pending, :published, user: user }
    let!(:collection_3) { create :collection, :pending, :unpublished, user: user }
    let!(:collection_4) { create :collection, :pending, :private, user: user }
    let!(:collection_5) { create :collection, :rejected, :opened, user: user, approver: user }
    let!(:collection_6) { create :collection, :rejected, user: user, approver: user }
    let!(:collection_7) { create :collection, user: user_2 }

    its(:collections_count) { is_expected.to eq 3 }
  end

  describe '#articles_count' do
    let!(:article_1) { create :article, :accepted, :published, user: user, approver: user }
    let!(:article_2) { create :article, :pending, :published, user: user }
    let!(:article_3) { create :article, :pending, :unpublished, user: user }
    let!(:article_4) { create :article, :rejected, user: user, approver: user }
    let!(:article_5) { create :article, user: user_2 }

    its(:articles_count) { is_expected.to eq 2 }
  end

  describe '#video_uploads_count' do
    let!(:report_1) { create :anime_video_report, :uploaded, user: user, state: 'accepted' }
    let!(:report_2) { create :anime_video_report, :uploaded, user: user, state: 'accepted' }
    let!(:report_3) { create :anime_video_report, :uploaded, user: user, state: 'accepted' }
    let!(:report_4) { create :anime_video_report, :uploaded, user: user, state: 'accepted' }
    let!(:report_5) { create :anime_video_report, :broken, user: user, state: 'accepted' }
    let!(:report_6) { create :anime_video_report, :broken, user: user, state: 'rejected' }
    let!(:report_7) { create :anime_video_report, :broken, state: 'accepted' }

    its(:video_uploads_count) { is_expected.to eq 4 }
  end

  describe '#video_versions_count, #video_uploads_count' do
    let(:anime_video) { create :anime_video }

    let!(:report_1) { create :anime_video_report, :uploaded, user: user, state: 'accepted' }
    let!(:report_2) { create :anime_video_report, :broken, user: user, state: 'accepted' }
    let!(:report_3) { create :anime_video_report, :broken, user: user, state: 'accepted' }
    let!(:report_4) { create :anime_video_report, :broken, user: user, state: 'accepted' }
    let!(:report_5) { create :anime_video_report, :broken, user: user, state: 'rejected' }
    let!(:report_6) { create :anime_video_report, :broken, state: 'accepted' }

    let!(:version_1) { create :version, user: user, item: anime_video, state: :accepted }
    let!(:version_2) { create :version, user: user, item: anime_video, state: :accepted }
    let!(:version_3) { create :version, user: user, item: anime, state: :pending }

    its(:video_versions_count) { is_expected.to eq 2 }
    its(:video_uploads_count) { is_expected.to eq 1 }
  end

  describe '#versions_count' do
    let!(:version_1) { create :version, user: user, item: anime, state: :taken }
    let!(:version_2) { create :version, user: user, item: anime, state: :accepted }
    let!(:version_3) { create :version, user: user, item: anime, state: :pending }
    let!(:version_4) { create :version, user: user, item: anime, state: :rejected }
    let!(:version_5) { create :version, user: user, item: anime, state: :deleted }
    let!(:version_6) { create :version, item: anime, state: :taken }
    let!(:version_7) do
      create :version,
        user: user,
        item: create(:anime_video),
        state: :taken
    end

    its(:versions_count) { is_expected.to eq 3 }
  end
end
