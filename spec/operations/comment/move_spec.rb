describe Comment::Move do
  subject! do
    described_class.call(
      comment: comment,
      to: site_rules_topic
    )
  end
  let(:comment) do
    create :comment,
      commentable: offtopic_topic,
      body: reply_sample
  end
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
      "[quote=t#{site_rules_topic.id};#{site_rules_topic.user_id};test]",
      "[quote=t#{site_rules_topic.id};#{site_rules_topic.user_id};test]",
      "[topic=#{site_rules_topic.id}]",
      ">?t#{site_rules_topic.id};#{site_rules_topic.user_id};test"
    ]
  end

  it do
    expect(comment.reload.commentable).to eq site_rules_topic
    expect(comment.body).to eq reply_converted[reply_samples.index(reply_sample)]
  end
end
