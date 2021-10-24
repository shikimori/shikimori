describe Comment::ConvertToReview do
  subject { described_class.call comment }
  let(:comment) do
    create :comment,
      body: 'x' * Review::MIN_BODY_SIZE,
      commentable: anim_topic
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
end
