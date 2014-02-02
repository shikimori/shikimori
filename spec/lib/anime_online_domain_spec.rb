require 'spec_helper'

describe AnimeOnlineDomain do
  describe :host do
    let(:anime) { build :anime }
    before { Anime.any_instance.stub(:adult?).and_return adult }
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
