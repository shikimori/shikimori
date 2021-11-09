describe Comment::ConvertToReview do
  subject { described_class.call comment, options }
  let(:options) { {} }
  let(:comment) do
    create :comment,
      body: 'x' * Review::MIN_BODY_SIZE,
      commentable: anime_topic
  end
  let(:anime_topic) { create :topic, linked: anime }
  let(:anime) { create :anime }

  it do
    is_expected.to be_persisted
    is_expected.to be_kind_of Review
    is_expected.to have_attributes(
      user: comment.user,
      anime: anime,
      body: comment.body,
      is_written_before_release: false
    )
    expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  context 'is_keep_comment' do
    let(:options) { { is_keep_comment: true } }

    it do
      is_expected.to be_persisted
      expect(comment.reload).to be_persisted
    end
  end
end
