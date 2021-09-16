describe Topic::Cleanup do
  let(:topic) { create :topic, comments_count: 4 }

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
    stub_const 'Topic::Cleanup::COMMENTS_OFFSET', 1
    if comment_1_is_summary
      comment_1.update_column :is_summary, true
    end

    allow(Comment::Cleanup).to receive :call
  end

  subject! { described_class.call topic }

  it do
    expect(Comment::Cleanup).to have_received(:call).twice
    expect(Comment::Cleanup).to have_received(:call).with(comment_1)
    expect(Comment::Cleanup).to have_received(:call).with(comment_2)
  end
end
