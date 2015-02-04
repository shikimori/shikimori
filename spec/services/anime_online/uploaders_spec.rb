require 'spec_helper'

describe AnimeOnline::Uploaders do
  before { AnimeOnline::Uploaders.reset }

  describe '.current_top' do
    subject { AnimeOnline::Uploaders.top }
    it { expect(subject).to_not be_blank }
  end

  describe '.current_top' do
    subject { AnimeOnline::Uploaders.current_top }
    context 'no_user' do
      it { expect(subject).to eq [] }
    end

    context 'ordered' do
      let(:user_1) { create :user, :user }
      let(:user_2) { create :user, :user }
      let!(:report_1) { create :anime_video_report, :uploaded, :accepted, user: user_1 }
      let!(:report_2_1) { create :anime_video_report, :uploaded, :accepted, user: user_2 }
      let!(:report_2_2) { create :anime_video_report, :uploaded, :accepted, user: user_2 }

      it { expect(subject).to eq [user_2, user_1] }
    end
  end

  describe '.responsible' do
    subject { AnimeOnline::Uploaders.responsible }
    let(:user_enough_accepted) { build_stubbed :user }
    let!(:report_1_1) { create :anime_video_report, :uploaded, :accepted, user: user_enough_accepted }
    let!(:report_1_2) { create :anime_video_report, :uploaded, :accepted, user: user_enough_accepted }

    let(:user_not_enough_accepted) { build_stubbed :user }
    let!(:report_2_1) { create :anime_video_report, :uploaded, :accepted, user: user_not_enough_accepted }

    let(:user_with_rejected) { build_stubbed :user }
    let!(:report_3_1) { create :anime_video_report, :uploaded, :accepted, user: user_with_rejected }
    let!(:report_3_2) { create :anime_video_report, :uploaded, :accepted, user: user_with_rejected }
    let!(:report_3_3) { create :anime_video_report, :uploaded, :rejected, user: user_with_rejected }

    before { stub_const 'AnimeOnline::Uploaders::ENOUGH_TO_TRUST', 2 }

    it { expect(subject).to eq [user_enough_accepted.id] }
  end

  describe '.trusted?' do
    before { stub_const 'AnimeOnline::Uploaders::ENOUGH_TO_TRUST', 1 }

    let!(:user) { build_stubbed :user, :user }
    let!(:user_admin) { build_stubbed :user, :admin }
    let!(:user_responsible) { build_stubbed :user, :user }
    let!(:report_1) { create :anime_video_report, :uploaded, :accepted, user: user_responsible }

    subject { AnimeOnline::Uploaders.trusted?(user_id) }

    it { expect(AnimeOnline::Uploaders.trusted?(user.id)).to eq false }
    it { expect(AnimeOnline::Uploaders.trusted?(user_admin.id)).to eq true }
    it { expect(AnimeOnline::Uploaders.trusted?(user_responsible.id)).to eq true }
  end
end
