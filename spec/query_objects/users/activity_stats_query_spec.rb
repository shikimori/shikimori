describe Users::ActivityStatsQuery do
  subject(:stats) { described_class.new user }

  describe '#call' do
    it do
      expect(stats.call.to_h).to have(9).items
      expect(stats.call).to be_kind_of Users::ActivityStats
    end
  end

  describe '#comments_count, #summaries_count' do
    let!(:comment_1) { create :comment, is_summary: false, user: user }
    let!(:comment_2) { create :comment, is_summary: false, user: user }
    let!(:comment_3) { create :comment, is_summary: true, body: 'x' * 1000, user: user }
    let!(:comment_4) { create :comment, is_summary: false, user: user_2 }

    its(:comments_count) { is_expected.to eq 2 }
    its(:summaries_count) { is_expected.to eq 1 }
  end

  describe '#reviews_count' do
    let!(:review_1) { create :review, :accepted, user: user, approver: user }
    let!(:review_2) { create :review, :pending, user: user }
    let!(:review_4) { create :review, :rejected, user: user, approver: user }
    let!(:review_5) { create :review, user: user_2 }

    its(:reviews_count) { is_expected.to eq 2 }
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
end
