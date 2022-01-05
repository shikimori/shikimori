describe Comments::Move do
  subject! do
    described_class.call(
      comment_ids: [comment.id],
      to: site_rules_topic,
      basis: comment_basis
    )
  end
  let(:comment) do
    create :comment,
      commentable: offtopic_topic,
      body: [
        "[quote=#{comment_basis.id};#{comment_basis.user.id};#{comment_basis.user.nickname}]zxc[/quote]",
        "[quote=c#{comment_basis.id};#{comment_basis.user.id};#{comment_basis.user.nickname}]zxc[/quote]"
      ].sample
  end
  let(:comment_basis) { create :comment, user: user_2 }

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
    expect(comment.body).to eq(
      "[quote=t#{site_rules_topic.id};#{comment_basis.user.id};#{comment_basis.user.nickname}]zxc[/quote]"
    )
  end
end
