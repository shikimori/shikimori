describe Topic::Cleanup do
  let(:topic) { create :topic, id: topic_id, comments_count: comments_count }
  let(:topic_id) { 987654345 }
  let(:comments_count) { comments_offset + 3 }

  let!(:comment_1) do
    create :comment,
      body: "[image=#{image_1.id}] [image=123456]",
      topic: topic,
      created_at: old_created_at,
      id: 9999990
  end
  let!(:comment_2) do
    create :comment,
      body: "[poster=#{image_2.id}]",
      topic: topic,
      created_at: old_created_at,
      id: 9999991
  end
  let!(:comment_3) do
    create :comment,
      body: "[image=#{image_3.id}]",
      topic: topic,
      created_at: fresh_created_at,
      id: 9999992
  end
  let!(:comment_4) do
    create :comment,
      body: "[image=#{image_4.id}]",
      topic: topic,
      created_at: old_created_at,
      id: 9999993
  end

  let(:comment_1_is_summary) { false }

  let(:old_created_at) { described_class::COMMENT_LIVE_TIME.ago - 1.day }
  let(:fresh_created_at) { described_class::COMMENT_LIVE_TIME.ago + 1.day }

  let(:image_1) { create :user_image }
  let(:image_2) { create :user_image }
  let(:image_3) { create :user_image }
  let(:image_4) { create :user_image }

  before do
    stub_const 'Topic::Cleanup::COMMENTS_OFFSET', comments_offset
    if comment_1_is_summary
      comment_1.update_column :is_summary, true
    end

    allow(Comment::Cleanup).to receive :call
  end
  let(:comments_offset) { 1 }

  subject! { described_class.call topic }

  it do
    expect(Comment::Cleanup).to have_received(:call).twice
    expect(Comment::Cleanup).to have_received(:call).with(comment_1)
    expect(Comment::Cleanup).to have_received(:call).with(comment_2)
  end

  context 'ignored topic' do
    let(:topic_id) { described_class::IGNORED_TOPIC_IDS.sample }
    it { expect(Comment::Cleanup).to_not have_received :call }
  end

  context 'too few comments in the topic' do
    let(:comments_count) { comments_offset }
    it { expect(Comment::Cleanup).to_not have_received :call }
  end
end
