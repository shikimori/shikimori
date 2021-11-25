describe Comments::Move do
  subject! do
    described_class.call(
      comment_ids: [comment.id],
      commentable: site_rules_topic
    )
  end
  let(:comment) { create :comment, commentable: offtopic_topic }

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
  end
end
