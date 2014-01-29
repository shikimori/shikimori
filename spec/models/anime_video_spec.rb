require 'spec_helper'

describe AnimeVideo do
  it { should belong_to :anime }
  it { should belong_to :author }

  it { should validate_presence_of :anime }
  it { should validate_presence_of :url }
  it { should validate_presence_of :source }
  it { should validate_numericality_of :episode }

  describe :scopes do
    describe :worked do
      subject { AnimeVideo.worked }

      context :filter_by_video_status do
        before do
          states.each do |s|
            create :anime_video, state: s, anime: create(:anime)
          end
        end

        context :good_states do
          let(:states) { ['working', 'uploaded' ] }
          it { should have(states.size).items }
        end

        context :bad_states do
          let(:states) { ['broken', 'wrong', 'banned', 'copyrighted' ] }
          it { should have(0).items }
        end
      end
    end

    describe :allowed_play do
      subject { AnimeVideo.allowed_play }

      context :true do
        context :by_censored do
          before { create :anime_video, anime: create(:anime, censored: false) }
          it { should have(1).items }
        end

        context :by_reting do
          before { create :anime_video, anime: create(:anime, rating: 'None') }
          it { should have(1).items }
        end
      end

      context :false do
        context :by_censored do
          before { create :anime_video, anime: create(:anime, censored: true) }
          it { should be_blank }
        end

        context :by_rating do
          before do
            Anime::ADULT_RATINGS.each { |rating|
              create :anime_video, anime: create(:anime, rating: rating)
            }
          end

          it { should be_blank }
        end
      end
    end
  end

  describe :before_save do
    before { anime_video.save }

    describe :check_ban do
      subject { anime_video.banned? }
      let(:anime_video) { build :anime_video, url: url }

      context :in_ban do
        let(:url) { 'http://v.kiwi.kz/v2/9l7tsj8n3has/' }
        it { should be_true }
      end

      context :no_ban do
        let(:url) { 'http://vk.com/j8n3/' }
        it { should be_false }
      end
    end

    describe :copyrighted do
      let(:anime_video) { build :anime_video, anime: create(:anime, id: anime_id) }
      subject { anime_video.copyrighted? }

      context :ban do
        let(:anime_id) { AnimeVideo::CopyrightBanAnimeIDs.first }
        it { should be_true }
      end

      context :not_ban do
        let(:anime_id) { 1 }
        it { should be_false }
      end
    end
  end

  describe :hosting do
    subject { build(:anime_video, url: url).hosting }

    context :valid_url do
      let(:url) { 'http://vk.com/video_ext.php?oid=1' }
      it { should eq 'vk.com' }
    end

    context :remove_www do
      let(:url) { 'http://www.vk.com?id=1' }
      it { should eq 'vk.com' }
    end

    context :second_level_domain do
      let(:url) { 'http://www.foo.bar.com/video?id=1' }
      it { should eq 'bar.com' }
    end

    context :alias_vk_com do
      let(:url) { 'http://vkontakte.ru/video?id=1' }
      it { should eq 'vk.com' }
    end
  end

  describe :state_machine do
    subject { video.state }
    let(:video) { create :anime_video }

    context :initial do
      it { should eq 'working' }
    end

    context :broken do
      before { video.broken }
      it { should eq 'broken' }
    end

    context :wrong do
      before { video.wrong }
      it { should eq 'wrong' }
    end

    context :ban do
      before { video.ban }
      it { should eq 'banned' }
    end
  end

  describe :allowed? do
    context :true do
      ['working', 'uploaded'].each do |state|
        specify { build(:anime_video, state: state).allowed?.should be_true }
      end
    end

    context :false do
      ['broken', 'wrong', 'banned'].each do |state|
        specify { build(:anime_video, state: state).allowed?.should be_false }
      end
    end
  end

  describe :copyright_ban do
    let(:anime_video) { build :anime_video, anime_id: anime_id }
    subject { anime_video.copyright_ban? }

    context :ban do
      let(:anime_id) { AnimeVideo::CopyrightBanAnimeIDs.first }
      it { should be_true }
    end

    context :not_ban do
      let(:anime_id) { 1 }
      it { should be_false }
    end
  end

  describe :uploader do
    let(:anime_video) { build_stubbed :anime_video, state: state }
    let(:user) { create :user, nickname: 'foo' }
    subject { anime_video.uploader }

    context :with_uploader do
      let(:state) { 'uploaded' }
      let(:kind) { state }
      let!(:anime_video_report) { create :anime_video_report, anime_video: anime_video, kind: kind, user: user }
      it { should eq user }
    end

    context :without_uploader do
      context :working do
        let(:state) { 'working' }
        it { should be_nil }
      end

      context :uploaded_without_report do
        let(:state) { 'uploaded' }
        it { should be_nil }
      end
    end
  end
end
