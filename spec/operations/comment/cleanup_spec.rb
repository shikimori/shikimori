describe Comment::Cleanup do
  let!(:comment) { create :comment, body: "[image=#{image.id}] [image=123456]" }
  let(:image) { create :user_image }

  subject! { described_class.call comment }

  it do
    expect { image.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(comment.reload.body).to eq '[image=deleted] [image=deleted]'
  end
end
