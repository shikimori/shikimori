describe Versions::DescriptionVersion do
  describe 'state_machine' do
    let(:version) { build_stubbed :description_version, state }

    describe '#accept_taken' do
      let(:state) { :taken }
      it { expect(version).to be_can_accept_taken }
    end

    describe '#take_accepted' do
      let(:state) { :accepted }
      it { expect(version).to be_can_take_accepted }
    end
  end

  describe '#fix_state' do
    let(:version) { create :description_version, state: state, item_diff: { description_ru: [old,new] } }
    before { version.fix_state }

    context 'accepted' do
      let(:state) { 'accepted' }

      context 'big changes' do
        let(:old) { 'aaaaaaa aaa' }
        let(:new) { 'aaaaaaa bbb' }

        it { expect(version).to be_accepted }
      end

      context 'small changes' do
        let(:old) { 'aaaaaaaa aa' }
        let(:new) { 'aaaaaaaa bb' }

        it { expect(version).to be_taken }
      end
    end

    context 'taken' do
      let(:state) { 'taken' }

      context 'big changes' do
        let(:old) { 'aaaaaaa aaa' }
        let(:new) { 'aaaaaaa bbb' }

        it { expect(version).to be_accepted }
      end

      context 'small changes' do
        let(:old) { 'aaaaaaaa aa' }
        let(:new) { 'aaaaaaaa bb' }
        it { expect(version).to be_taken }
      end
    end
  end
end
