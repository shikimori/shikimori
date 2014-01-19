require 'spec_helper'

describe AnimeVideo do
  it { should belong_to :anime }
  it { should belong_to :author }

  it { should validate_presence_of :anime }
  it { should validate_presence_of :url }
  it { should validate_presence_of :source }
  it { should validate_numericality_of :episode }

  describe :scopes do
    subject { AnimeVideo.available }
    before do
      states.each do |s|
        create :anime_video, state: s
      end
    end

    context :good_states do
      let(:states) { ['working', 'uploaded' ] }
      it { should have(states.size).items }
    end

    context :bad_states do
      let(:states) { ['broken', 'wrong', 'banned' ] }
      it { should have(0).items }
    end
  end

  describe :before_save do
    describe :check_ban do
      subject { anime.banned? }
      let(:anime) { build :anime_video, url: url }
      before { anime.save }

      context :in_ban do
        let(:url) { 'http://v.kiwi.kz/v2/9l7tsj8n3has/' }
        it { should be_true }
      end

      context :no_ban do
        let(:url) { 'http://vk.com/j8n3/' }
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
end
