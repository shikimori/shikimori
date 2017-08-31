describe PollVariant do
  describe 'relations' do
    it { is_expected.to belong_to :poll }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :label }
  end

  describe 'instance methods' do
    describe '#text_html' do
      let(:poll) { build_stubbed :poll_variant, label: '[i]test[/i]' }
      it { expect(poll.label_html).to eq '<em>test</em>' }
    end
  end
end
