describe Comment::ConvertToReview do
  subject(:review) { described_class.call comment, options }
  let(:options) { {} }
  let(:comment) do
    create :comment,
      id: 99999,
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
  let!(:reply_2) do
    create :comment,
      commentable: anime_topic,
      body: reply_sample
  end
  let!(:reply_3) { create :comment, commentable: anime_topic }

  let(:reply_samples) do
    [
      '[quote=99999]',
      "[quote=99999;#{user.id};test]",
      "[quote=c99999;#{user.id};test]",
      '[comment=99999]',
      ">?c99999;#{user.id};test"
    ]
  end
  let(:reply_sample) { reply_samples.sample }
  let(:reply_converted) do
    [
      '[quote=99999]',
      "[quote=r#{review.id};#{user.id};test]",
      "[quote=r#{review.id};#{user.id};test]",
      "[review=#{review.id}]",
      ">?r#{review.id};#{user.id};test"
    ]
  end

  let!(:abuse_request) { create :abuse_request, comment: comment }
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

    expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(abuse_request.reload).to have_attributes(
      comment_id: nil,
      review_id: subject.id
    )
    expect(ban.reload).to have_attributes(
      comment_id: nil,
      review_id: subject.id
    )

    expect(reply_1.reload.commentable_type).to eq Review.name
    expect(reply_1.commentable_id).to eq review.id
    expect(reply_2.reload.commentable_type).to eq Review.name
    expect(reply_2).to have_attributes(
      commentable_id: review.id,
      body: reply_converted[reply_samples.index(reply_sample)]
    )
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
