describe Versions::DescriptionVersion do
  describe '#fix_state' do
    let(:version) { create :description_version, state: state, item_diff: { description: [old,new] } }
    before { version.fix_state }

    context 'accepted' do
      let(:state) { 'accepted' }

      context 'big changes' do
        let(:old) { 'aaaaaaa aa' }
        let(:new) { 'aaaaaaa bb' }

        it { expect(version).to be_accepted }
      end

      context 'small changes' do
        let(:old) { 'aaaaaaaa a' }
        let(:new) { 'aaaaaaaa b' }

        it { expect(version).to be_taken }
      end
    end

    context 'taken' do
      let(:state) { 'taken' }

      context 'big changes' do
        let(:old) { 'aaaaaaa aa' }
        let(:new) { 'aaaaaaa bb' }

        it { expect(version).to be_accepted }
      end

      context 'small changes' do
        let(:old) { 'aaaaaaaa a' }
        let(:new) { 'aaaaaaaa b' }
        it { expect(version).to be_taken }
      end
    end
  end
end
