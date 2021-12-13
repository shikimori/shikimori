describe Review::ConvertToComment do
  subject(:comment) { described_class.call review }

  let(:review) do
    create :review,
      body: ('x' * Review::MIN_BODY_SIZE) + "\n[replies=99999999,99999998]",
      anime: anime,
      created_at: 1.day.ago,
      updated_at: 1.hour.ago
  end
  let!(:reply_1) do
    create :comment,
      id: 99999999,
      body: "zxc [replies=#{reply_3.id}]",
      commentable: review
  end
  let!(:reply_2) { create :comment, id: 99999998, commentable: review }
  let!(:reply_3) { create :comment, id: 99999997, commentable: review }

  let!(:anime_topic) { create :anime_topic, linked: anime }
  let(:anime) { create :anime }

  let!(:abuse_request) { create :abuse_request, comment_id: nil, review: review }
  let!(:ban) { create :ban, comment_id: nil, review: review, moderator: user }

  it do
    is_expected.to be_persisted
    is_expected.to be_kind_of Comment
    is_expected.to have_attributes(
      user: review.user,
      commentable: anime_topic,
      body: review.body
    )
    expect(subject.created_at).to be_within(0.1).of comment.created_at
    expect(subject.updated_at).to be_within(0.1).of comment.updated_at

    expect { review.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(abuse_request.reload).to have_attributes(
      comment_id: subject.id,
      review_id: nil
    )
    expect(ban.reload).to have_attributes(
      comment_id: subject.id,
      review_id: nil
    )

    expect(reply_1.reload.commentable_type).to eq Topic.name
    expect(reply_1.commentable_id).to eq anime_topic.id
    expect(reply_2.reload.commentable_type).to eq Topic.name
    expect(reply_3.reload.commentable_type).to eq Topic.name
  end
end
