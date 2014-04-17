require 'spec_helper'

describe AnimeOnline::AdsPolicy do
  let(:policy) { AnimeOnline::AdsPolicy }

  describe :host_allowed do
    subject { policy.host_allowed? host }

    context :host_play do
      let(:host) { AnimeOnlineDomain::HOST_PLAY }
      it { should be_true }
    end

    context :xhost_play do
      let(:host) { AnimeOnlineDomain::HOST_XPLAY }
      it { should be_false }
    end
  end
end
