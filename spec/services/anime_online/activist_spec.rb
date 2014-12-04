require 'spec_helper'

describe AnimeOnline::Activists do
  before { stub_const('AnimeOnline::Activists::ENOUGH_TO_TRUST_RUTUBE', 2) }
  before { AnimeOnline::Activists.reset }
  let(:user) { create(:user, id: 9999) }

  describe ".rutube_responsible" do
    subject { AnimeOnline::Activists.rutube_responsible }

    context :empty do
      it { expect(subject).to eq [] }
    end

    context :not_enough do
      let(:anime_video) { create :anime_video, url: "http://rutube.ru/1" }
      let!(:report) { create(:anime_video_report, anime_video: anime_video, state: 'accepted', kind: 'broken', user: user) }

      it { expect(subject).to eq [] }
    end

    context :enough_but_other_hosting do
      let(:anime_video_1) { create :anime_video, url: "http://vk.ru/1" }
      let(:anime_video_2) { create :anime_video, url: "http://vk.ru/2" }
      let!(:report_1) { create(:anime_video_report, anime_video: anime_video_1, state: 'accepted', kind: 'broken', user: user) }
      let!(:report_2) { create(:anime_video_report, anime_video: anime_video_2, state: 'accepted', kind: 'broken', user: user) }

      it { expect(subject).to eq [] }
    end

    context :enough do
      let(:anime_video_1) { create :anime_video, url: "http://rutube.ru/1" }
      let(:anime_video_2) { create :anime_video, url: "http://rutube.ru/2" }
      let!(:report_1) { create(:anime_video_report, anime_video: anime_video_1, state: 'accepted', kind: 'broken', user: user) }
      let!(:report_2) { create(:anime_video_report, anime_video: anime_video_2, state: 'accepted', kind: 'broken', user: user) }

      it { expect(subject).to eq [user.id] }
    end

    context :enough_but_has_rejected do
      let(:anime_video_1) { create :anime_video, url: "http://rutube.ru/1" }
      let(:anime_video_2) { create :anime_video, url: "http://rutube.ru/2" }
      let(:anime_video_3) { create :anime_video, url: "http://rutube.ru/3" }
      let!(:report_1) { create(:anime_video_report, anime_video: anime_video_1, state: 'accepted', kind: 'broken', user: user) }
      let!(:report_2) { create(:anime_video_report, anime_video: anime_video_2, state: 'accepted', kind: 'broken', user: user) }
      let!(:report_3) { create(:anime_video_report, anime_video: anime_video_3, state: 'rejected', kind: 'broken', user: user) }

      it { expect(subject).to eq [] }
    end
  end

  describe ".can_trust" do
    subject { AnimeOnline::Activists.can_trust?(user.id, "rutube.ru") }

    context :false do
      it { expect(subject).to be_false }
    end

    context :true do
      let(:anime_video_1) { create :anime_video, url: "http://rutube.ru/1" }
      let(:anime_video_2) { create :anime_video, url: "http://rutube.ru/2" }
      let!(:report_1) { create(:anime_video_report, anime_video: anime_video_1, state: 'accepted', kind: 'broken', user: user) }
      let!(:report_2) { create(:anime_video_report, anime_video: anime_video_2, state: 'accepted', kind: 'broken', user: user) }

      it { expect(subject).to be_true }
    end
  end
end
