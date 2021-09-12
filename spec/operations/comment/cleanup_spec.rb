describe Comment::Cleanup do
  let!(:comment) do
    create :comment,
      body: "[image=#{image.id}]\n> > [image=123456]\n\n`[image=234567]`"
  end
  let(:image) { create :user_image }

  before do
    comment.update_column :is_summary, true if is_summary
  end
  let(:is_summary) { true }
  subject! { described_class.call comment, options }
  let(:options) { {} }

  it do
    expect(image.reload).to be_persisted
    expect(comment.reload.body).to eq(
      "[image=#{image.id}]\n> > [image=123456]\n\n`[image=234567]`"
    )
  end

  context 'is_cleanup_summaries' do
    let(:options) { { is_cleanup_summaries: true } }
    it do
      expect { image.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(comment.reload.body).to eq(
        "[image=deleted]\n> > [image=123456]\n\n`[image=234567]`"
      )
    end
  end

  context 'is_cleanup_quotes' do
    let(:is_summary) { false }
    let(:options) { { is_cleanup_quotes: true } }
    it do
      expect { image.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(comment.reload.body).to eq(
        "[image=deleted]\n> > [image=deleted]\n\n`[image=deleted]`"
      )
    end
  end
end
