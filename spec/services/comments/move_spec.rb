describe Comments::Move do
  subject! do
    described_class.call(
      comment_ids: [comment.id],
      commentable: site_rules_topic,
      from_reply: from_reply,
      to_reply: to_reply
    )
  end
  let(:comment) do
    create :comment,
      commentable: offtopic_topic,
      body: [
        "[quote=#{from_reply.id};#{from_reply.user.id};#{from_reply.user.nickname}]zxc[/quote]",
        "[quote=c#{from_reply.id};#{from_reply.user.id};#{from_reply.user.nickname}]zxc[/quote]"
      ].sample
  end
  let(:from_reply) { build_stubbed :comment, user: user_2 }
  let(:to_reply) { offtopic_topic }

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
    expect(comment.body).to eq(
      "[quote=t#{to_reply.id};#{from_reply.user.id};#{from_reply.user.nickname}]zxc[/quote]"
    )
  end
end
