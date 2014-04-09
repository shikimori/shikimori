require 'spec_helper'

describe AnimeOnline::AdsPolicy do
  let(:policy) { AnimeOnline::AdsPolicy }

  describe :top_line_allowed do
    subject { policy.top_line_allowed? host, action_name }

    context :host_play do
      let(:host) { AnimeOnlineDomain::HOST_PLAY }

      context :index do
        let(:action_name) { 'index' }
        it { should be_false }
      end

      context :show do
        let(:action_name) { 'show' }
        it { should be_true }
      end
    end

    context :xhost_play do
      let(:host) { AnimeOnlineDomain::HOST_XPLAY }

      context :index do
        let(:action_name) { 'index' }
        it { should be_false }
      end

      context :show do
        let(:action_name) { 'show' }
        it { should be_false }
      end
    end
  end
end
