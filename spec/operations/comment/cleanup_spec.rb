describe Comment::Cleanup do
  let!(:comment) { create :comment, body: "[image=#{image.id}] [image=123456]" }
  let(:image) { create :user_image }

  before { comment.update_column :is_summary, true }
  subject! { described_class.call comment, options }
  let(:options) { {} }

  it do
    expect(image.reload).to be_persisted
    expect(comment.reload.body).to eq "[image=#{image.id}] [image=123456]"
  end

  context 'is_cleanup_summaries' do
    let(:options) { { is_cleanup_summaries: true } }
    it do
      expect { image.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(comment.reload.body).to eq '[image=deleted] [image=deleted]'
    end
  end
end
