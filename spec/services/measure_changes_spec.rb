describe MeasureChanges do
  let(:service) { MeasureChanges.new old, new }

  describe '#enough?' do
    context 'blank old, blank new' do
      let(:old) { '' }
      let(:new) { '' }
      it { expect(service).to_not be_enough }
      it { expect(service.text_change).to eq 0 }
    end

    context 'blank old' do
      let(:old) { '' }
      let(:new) { 'zz' }
      it { expect(service).to be_enough }
      it { expect(service.text_change).to eq 100 }
    end

    context 'size decrease' do
      let(:old) { 'aaaaaaa aa' }
      let(:new) { 'aaaaaaa a' }
      it { expect(service).to_not be_enough }
      it { expect(service.text_change).to eq 10.0 }
    end

    context 'size increase' do
      let(:old) { 'aaaaaaaaa ' }

      context '< 25% increase' do
        let(:new) { 'aaaaaaaaa a' }
        it { expect(service).to_not be_enough }
      end

      context '>= 25% increase' do
        let(:new) { 'aaaaaaaaa aaa' }
        it { expect(service).to be_enough }
      end
    end

    context 'content change' do
      let(:old) { 'aa aa aa aa aa' }

      context '< 25% change' do
        let(:new) { 'aa aa aa aa bb' }
        it { expect(service).to_not be_enough }
        it { expect(service.text_change).to eq 14.285714285714286 }
      end

      context '>= 25% change' do
        let(:new) { 'aa aa aa bb bb' }
        it { expect(service).to be_enough }
        it { expect(service.text_change).to eq 35.714285714285715 }
      end
    end
  end
end
