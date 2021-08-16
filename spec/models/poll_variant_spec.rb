describe PollVariant do
  describe 'relations' do
    it { is_expected.to belong_to :poll }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :label }
  end

  describe 'instance methods' do
    describe '#text_html' do
      let(:poll) { build_stubbed :poll_variant, label: label }

      context 'regular bbcode' do
        let(:label) { '[i]test[/i]' }
        it { expect(poll.label_html).to eq '<em>test</em>' }
      end

      context 'link' do
        let(:label) { 'https://ya.ru' }
        it do
          expect(poll.label_html).to eq(
            '<a class="b-link" href="https://ya.ru" target="_blank" ' \
              'rel="noopener noreferrer nofollow">ya.ru</a>'
          )
        end
      end
    end
  end
end
