describe Comment::ConvertToReview do
  subject(:review) { described_class.call comment, options }
  let(:options) { {} }
  let(:comment) do
    create :comment,
      body: ('x' * Review::MIN_BODY_SIZE) + "\n[replies=#{reply_1.id},#{reply_2.id}]",
      commentable: anime_topic,
      created_at: 1.day.ago,
      updated_at: 1.hour.ago
  end
  let(:anime_topic) { create :anime_topic, linked: anime }
  let(:anime) { create :anime }

  let!(:reply_1) do
    create :comment,
      body: "zxc [replies=#{reply_3.id}]",
      commentable: anime_topic
  end
  let!(:reply_2) { create :comment, commentable: anime_topic }
  let!(:reply_3) { create :comment, commentable: anime_topic }

  it do
    is_expected.to be_persisted
    is_expected.to be_kind_of Review
    is_expected.to have_attributes(
      user: comment.user,
      anime: anime,
      body: comment.body,
      is_written_before_release: false
    )
    expect(subject.created_at).to be_within(0.1).of comment.created_at
    expect(subject.updated_at).to be_within(0.1).of comment.updated_at
    expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(reply_1.reload.commentable_type).to eq Review.name
    expect(reply_1.commentable_id).to eq review.id
    expect(reply_2.reload.commentable_type).to eq Review.name
    expect(reply_3.reload.commentable_type).to eq Review.name
  end

  context 'is_keep_comment' do
    let(:options) { { is_keep_comment: true } }

    it do
      is_expected.to be_persisted
      expect(comment.reload).to be_persisted
      expect(reply_1.reload.commentable_type).to eq Topic.name
    end
  end
end
