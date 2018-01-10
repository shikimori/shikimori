describe Topic::Cleanup do
  let(:topic) { create :topic, comments_count: 3 }

  let!(:comment_1) { create :comment, body: "[image=#{image_1.id}] [image=123456]", topic: topic }
  let!(:comment_2) { create :comment, body: "[poster=#{image_2.id}]", topic: topic }
  let!(:comment_3) { create :comment, body: "[image=#{image_3.id}]", topic: topic }

  let(:image_1) { create :user_image }
  let(:image_2) { create :user_image }
  let(:image_3) { create :user_image }

  before { stub_const 'Topic::Cleanup::COMMENTS_OFFSET', 1 }

  subject! { described_class.call topic }

  it do
    expect { image_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { image_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(image_3.reload).to be_persisted

    expect(comment_1.reload.body).to eq '[image=deleted] [image=deleted]'
    expect(comment_2.reload.body).to eq '[poster=deleted]'
    expect(comment_3.reload.body).to eq "[image=#{image_3.id}]"
  end
end
