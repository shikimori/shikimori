describe Comments::RepliesByBbCode do
  subject do
    described_class.call(
      model: comment,
      commentable: comment.commentable
    )
  end

  let(:commentable_1) { site_rules_topic }
  let(:commentable_2) { offtopic_topic }
  let!(:comment) do
    create :comment,
      id: comment_id,
      body: ('x' * Review::MIN_BODY_SIZE) +
        "\n[replies=#{reply_1_2.id},#{reply_2_1.id},234567]" \
          "\n[replies=#{reply_3_1.id},#{reply_1_2.id}]",
      commentable: commentable_1
  end
  let(:comment_id) { 999999 }
  let(:reply_2_1) do
    create :comment,
      body: "zxc [replies=#{reply_4_1.id},#{reply_3_1.id},#{comment_id},234567]",
      commentable: commentable_1
  end
  let(:reply_3_1) { create :comment, commentable: commentable_1 }
  let(:reply_4_1) { create :comment, commentable: commentable_1 }
  let(:reply_1_2) { create :comment, commentable: commentable_2 }

  it { is_expected.to eq [reply_2_1, reply_4_1, reply_3_1] }
end
