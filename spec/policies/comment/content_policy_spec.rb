describe Comment::ContentPolicy do
  describe '.check_height?' do
    subject { described_class.check_height? comment }
    let(:comment) { build_stubbed :comment, body: body }
    let(:body) { 'a' * described_class::BOUNDARY_BODY_SIZE }

    context 'persisted' do
      context 'long body' do
        it { is_expected.to eq true }
      end

      context 'short body' do
        let(:body) { 'a' * (described_class::BOUNDARY_BODY_SIZE - 1) }
        it { is_expected.to eq false }

        describe 'newlines' do
          context 'too many' do
            let(:body) { "a\n" * described_class::BOUNDARY_NEWLINES_AMOUNT }
            it { is_expected.to eq true }
          end

          context 'not enough' do
            let(:body) { "a\n" * (described_class::BOUNDARY_NEWLINES_AMOUNT - 1) }
            it { is_expected.to eq false }
          end
        end

        describe 'bbcodes' do
          let(:body) { ['[img', '[imag', '[poster'].sample }
          it { is_expected.to eq true }
        end
      end
    end

    context 'new record' do
      before { allow(comment).to receive(:persisted?).and_return false }
      it { is_expected.to eq false }
    end
  end
end
