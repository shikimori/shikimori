describe MeasureChanges do
  let(:service) { MeasureChanges.new old, new }

  describe '#enough?' do
    context 'blank old, blank new' do
      let(:old) { '' }
      let(:new) { '' }
      it { expect(service).to_not be_enough }
    end

    context 'blank old' do
      let(:old) { '' }
      let(:new) { 'zz' }
      it { expect(service).to be_enough }
    end

    context 'size decrease' do
      let(:old) { 'aaaaaaaaaa' }
      let(:new) { 'aaaaaaaaa' }
      it { expect(service).to_not be_enough }
    end

    context 'size increase' do
      let(:old) { 'aaaaaaaaaa' }

      context 'small increase' do
        let(:new) { 'aaaaaaaaaaaa' }
        it { expect(service).to_not be_enough }
      end

      context '>= 25% increase' do
        let(:new) { 'aaaaaaaaaaaaa' }
        it { expect(service).to be_enough }
      end
    end

  end
end
