describe Comment::Move do
  subject! do
    described_class.call(
      comment: comment,
      commentable: site_rules_topic,
      from_basis: from_basis,
      to_basis: to_basis
    )
  end
  let(:comment) do
    create :comment,
      commentable: offtopic_topic,
      body: reply_sample
  end

  let(:from_basis) { build_stubbed :comment }
  let(:to_basis) { offtopic_topic }

  let(:reply_samples) do
    [
      # invalid replacement
      "[quote=#{from_basis.id}]",
      "[quote=#{from_basis.id + 1};#{user.id};test]",
      "[comment=#{from_basis.id + 1}]",
      ">?c#{from_basis.id + 1};#{user.id};test",
      # valid replacement
      "[quote=#{from_basis.id};#{user.id};test]",
      "[quote=c#{from_basis.id};#{user.id};test]",
      "[comment=#{from_basis.id}]",
      "[comment=#{from_basis.id};1",
      ">?c#{from_basis.id};#{user.id};test"
    ]
  end
  let(:reply_sample) { reply_samples.sample }
  let(:reply_converted) do
    [
      # invalid replacement
      "[quote=#{from_basis.id}]",
      "[quote=#{from_basis.id + 1};#{user.id};test]",
      "[comment=#{from_basis.id + 1}]",
      ">?c#{from_basis.id + 1};#{user.id};test",
      # valid replacement
      "[quote=t#{to_basis.id};#{user.id};test]",
      "[quote=t#{to_basis.id};#{user.id};test]",
      "[topic=#{to_basis.id}]",
      "[topic=#{to_basis.id};1",
      ">?t#{to_basis.id};#{user.id};test"
    ]
  end

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
    expect(comment.body).to eq reply_converted[reply_samples.index(reply_sample)]
  end
end
