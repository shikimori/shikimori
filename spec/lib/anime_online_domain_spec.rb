describe AnimeOnlineDomain do
  describe :host do
    let(:anime) { build :anime }
    before { allow_any_instance_of(Anime).to receive(:adult?).and_return adult }
    subject { AnimeOnlineDomain::host anime }

    context :play do
      let(:adult) { false }
      it { should eq AnimeOnlineDomain::HOST_PLAY }
    end

    context :xplay do
      let(:adult) { true }
      it { should eq AnimeOnlineDomain::HOST_XPLAY }
    end
  end
end
