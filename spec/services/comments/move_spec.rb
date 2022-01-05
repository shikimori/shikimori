describe Comments::Move do
  subject! do
    described_class.call(
      comment_ids: [comment.id],
      commentable: site_rules_topic,
      from_basis: from_basis,
      to_basis: to_basis
    )
  end
  let(:comment) do
    create :comment,
      commentable: offtopic_topic,
      body: [
        "[quote=#{from_basis.id};#{from_basis.user.id};#{from_basis.user.nickname}]zxc[/quote]",
        "[quote=c#{from_basis.id};#{from_basis.user.id};#{from_basis.user.nickname}]zxc[/quote]"
      ].sample
  end
  let(:from_basis) { build_stubbed :comment, user: user_2 }
  let(:to_basis) { offtopic_topic }

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
    expect(comment.body).to eq(
      "[quote=t#{to_basis.id};#{from_basis.user.id};#{from_basis.user.nickname}]zxc[/quote]"
    )
  end
end
