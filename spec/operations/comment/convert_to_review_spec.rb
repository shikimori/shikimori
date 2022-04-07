describe Comment::ConvertToReview do
  subject(:review) do
    described_class.call(
      comment: comment,
      actor: actor,
      is_keep_comment: is_keep_comment
    )
  end
  let(:comment) do
    create :comment,
      id: 99999,
      body: ('x' * Review::MIN_BODY_SIZE) + "\n[replies=#{reply_1.id},#{reply_2.id}]",
      commentable: anime_topic,
      created_at: 1.day.ago,
      updated_at: 1.hour.ago
  end
  let(:is_keep_comment) { nil }
  let(:actor) { user_3 }

  let(:anime_topic) { create :anime_topic, linked: anime }
  let(:anime) { create :anime }

  let!(:reply_1) do
    create :comment,
      body: "zxc [replies=#{reply_3.id}]",
      commentable: anime_topic
  end
  let!(:reply_2) do
    create :comment,
      commentable: anime_topic,
      body: "[quote=99999;#{user.id};test]"
  end
  let!(:reply_3) { create :comment, commentable: anime_topic }

  let!(:other_abuse_request) do
    create :abuse_request, :summary, comment: comment
  end
  let!(:offtopic_abuse_request) do
    create :abuse_request, :offtopic, comment: comment
  end
  let!(:convert_review_abuse_request) do
    create :abuse_request, :convert_review, comment: comment
  end
  let!(:ban) { create :ban, :no_callbacks, comment: comment, moderator: user }

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

    review_topic = subject.maybe_topic(:ru)
    expect(review_topic).to be_present
    expect(review_topic).to be_persisted
    expect(review_topic).to be_kind_of Topics::EntryTopics::ReviewTopic

    expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(other_abuse_request.reload).to have_attributes(
      state: 'pending',
      comment_id: nil,
      topic_id: review_topic.id,
      approver_id: nil
    )
    expect(offtopic_abuse_request.reload).to have_attributes(
      state: 'rejected',
      comment_id: nil,
      topic_id: review_topic.id,
      approver_id: actor.id
    )
    expect(convert_review_abuse_request.reload).to have_attributes(
      state: 'accepted',
      comment_id: nil,
      topic_id: review_topic.id,
      approver_id: actor.id
    )
    expect(ban.reload).to have_attributes(
      comment_id: nil,
      topic_id: review_topic.id
    )

    expect(reply_1.reload.commentable_id).to eq review_topic.id
    expect(reply_1.commentable_type).to eq Topic.name
    expect(reply_2.reload.commentable_id).to eq review_topic.id
    expect(reply_2.body).to eq "[quote=t#{review_topic.id};#{user.id};test]"
    expect(reply_3.reload.commentable_id).to eq review_topic.id
  end

  context 'is_keep_comment' do
    let(:is_keep_comment) { true }

    it do
      is_expected.to be_persisted
      expect(comment.reload).to be_persisted
      expect(reply_1.reload.commentable_id).to eq anime_topic.id
      expect(reply_1.reload.commentable_type).to eq Topic.name
    end
  end
end
