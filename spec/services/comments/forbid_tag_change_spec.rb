describe Comments::ForbidTagChange do
  subject do
    described_class.call(
      model: comment,
      field: :body,
      tag_regexp: /(\[ban=\d+\])/,
      tag_error_label: '[ban]'
    )
  end
  let(:comment) do
    create :comment, :skip_forbid_tags_change, body: initial_body
  end
  let(:initial_body) { 'test [ban=123]' }
  let(:error_message) { '[ban] тег изменять нельзя' }

  before { comment.body = new_body }

  context 'no tag changes' do
    let(:new_body) { 'zxc [ban=123]' }

    it do
      is_expected.to eq true
      expect(comment.errors[:body]).to be_empty
    end
  end

  context 'removed tag' do
    let(:new_body) { 'zxc' }

    it do
      is_expected.to eq false
      expect(comment.errors[:body]).to eq [error_message]
    end
  end

  context 'added tag' do
    let(:new_body) { 'zxc [ban=123] [ban=1234]' }

    it do
      is_expected.to eq false
      expect(comment.errors[:body]).to eq [error_message]
    end
  end

  context 'changed tag' do
    let(:new_body) { 'zxc [ban=1234]' }

    it do
      is_expected.to eq false
      expect(comment.errors[:body]).to eq [error_message]
    end
  end
end
