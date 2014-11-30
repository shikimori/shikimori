require 'spec_helper'

describe AnimeOnline::Uploaders do
  describe '.current_top' do
    subject { AnimeOnline::Uploaders.top }
    it { expect(subject).to_not be_blank }
  end

  describe '.current_top' do
    subject { AnimeOnline::Uploaders.current_top }
    context :no_user do
      #it { is_expected.to eq [] }
      it { expect(subject).to eq [] }
    end

    context :ordered do
      let(:user_1) { build_stubbed(:user) }
      let(:user_2) { build_stubbed(:user) }
      let!(:report_1) { create(:anime_video_report, user: user_1, state: 'accepted', kind: :uploaded) }
      let!(:report_2_1) { create(:anime_video_report, user: user_2, state: 'accepted', kind: :uploaded) }
      let!(:report_2_2) { create(:anime_video_report, user: user_2, state: 'accepted', kind: :uploaded) }
      it { expect(subject).to have(2).items }
      it { expect(subject.first).to eq user_2.id }
      it { expect(subject.second).to eq user_1.id }
    end
  end
end
