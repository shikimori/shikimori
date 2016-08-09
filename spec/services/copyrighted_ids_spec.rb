describe CopyrightedIds do
  let(:service) { CopyrightedIds.instance }

  describe '#change' do
    context 'copyrighted 1x' do
      it do
        expect(service.change 9_999_999, :anime).to eq 'z9999999'
      end
    end

    context 'copyrighted 2x' do
      it do
        expect(service.change 8_888_888, :anime).to eq 'a8888888'
      end
    end

    context 'copyrighted 3x' do
      it do
        expect(service.change 7_777_777, :anime).to eq 'zz7777777'
      end
    end

    context 'copyrighted 4x' do
      it do
        expect(service.change 6_666_666, :anime).to eq 'az6666666'
      end
    end

    context 'copyrighted 5x' do
      it do
        expect(service.change 5_555_555, :anime).to eq 'zzz5555555'
      end
    end

    context 'not copyrighted' do
      it { expect(service.change 1, :anime).to eq '1' }
    end

    context 'another type copyrighted' do
      it { expect(service.change 8_888_888, :zzz).to eq '8888888' }
    end
  end

  describe '#restore' do
    context 'copyrighted' do
      context 'changed' do
        it do
          expect(service.restore 'z9999999-neo-ranga', :anime).to eq 9_999_999
        end
      end

      context 'original' do
        let!(:anime) { create :anime, id: 9_999_999 }
        it do
          expect { service.restore '9999999-neo-ranga', :anime }
            .to raise_error CopyrightedResource
        end
      end
    end

    context 'twice copyrighted' do
      it do
        expect(service.restore 'a8888888', :anime).to eq 8_888_888
      end
    end

    context 'thrice copyrighted' do
      it do
        expect(service.restore 'za7777777', :anime).to eq 7_777_777
      end
    end

    context 'not copyrighted' do
      it { expect(service.restore '25', :anime).to eq 25 }
    end
  end

  describe '#restore_id' do
    it { expect(service.restore_id('z8')).to eq 8 }
    it { expect(service.restore_id('8')).to eq 8 }
  end
end
