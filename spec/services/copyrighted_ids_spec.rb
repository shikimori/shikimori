describe CopyrightedIds do
  let(:service) { CopyrightedIds.instance }

  describe '#change' do
    context 'copyrighted' do
      it { expect(service.change 145, :anime)
        .to eq "#{CopyrightedIds::MARKER}145" }
    end

    context 'twice copyrighted' do
      it { expect(service.change 9999999, :anime)
        .to eq "#{CopyrightedIds::MARKER*2}9999999" }
    end

    context 'not copyrighted' do
      it { expect(service.change 1, :anime).to eq 1 }
    end
  end

  describe '#restore' do
    context 'copyrighted' do
      context 'changed' do
        it do
          expect(
            service.restore "#{CopyrightedIds::MARKER}145-neo-ranga", :anime
          ).to eq 145 }
      end

      context 'original' do
        let!(:anime) { create :anime, id: 145 }
        it { expect{service.restore '145-neo-ranga', :anime}
          .to raise_error CopyrightedResource }
      end
    end

    context 'twice copyrighted' do
      it { expect(service.restore "#{CopyrightedIds::MARKER*2}9999999", :anime)
        .to eq 9999999 }
    end

    context 'not copyrighted' do
      it { expect(service.restore '25', :anime).to eq 25 }
    end
  end
end
