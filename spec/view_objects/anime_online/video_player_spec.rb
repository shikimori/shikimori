describe AnimeOnline::VideoPlayer do
  let(:player) { AnimeOnline::VideoPlayer.new anime }
  let(:anime) { build :anime }

  describe '#videos' do
    subject { player.videos }
    let(:anime) { create :anime }
    let(:episode) { 1 }

    context 'anime without videos' do
      it { is_expected.to be_blank }
    end

    context 'anime with one video' do
      let!(:video) { create :anime_video, episode: episode, anime: anime }
      it { is_expected.to eq [video] }
    end

    context 'anime with two videos' do
      let!(:video_1) { create :anime_video, episode: episode, anime: anime }
      let!(:video_2) { create :anime_video, episode: episode, anime: anime }
      it { is_expected.to eq [video_2, video_1] }
    end

    context 'not working' do
      let!(:video_1) { create :anime_video, episode: episode, state: :broken }
      it { is_expected.to be_empty }
    end

    context 'not only working' do
      let!(:video_1) { create :anime_video, episode: episode, state: 'working', anime: anime }
      let!(:video_2) { create :anime_video, episode: episode, state: 'broken', anime: anime }
      let!(:video_3) { create :anime_video, episode: episode, state: 'wrong', anime: anime }
      it { is_expected.to eq [video_3, video_2, video_1] }
    end
  end

  describe '#videos_by_kind' do
    subject { player.videos_by_kind }
    let(:anime) { create :anime }

    context 'without vidoes' do
      it { is_expected.to eq({}) }
    end

    context 'not working are ignored' do
      let!(:video_broken) { create :anime_video, state: 'broken', anime: anime }
      it { is_expected.to eq({}) }
    end

    context 'vk first' do
      let!(:video_vk) do
        create :anime_video, :fandub,
          url: attributes_for(:anime_video)[:url],
          anime: anime
      end
      let!(:video_other) do
        create :anime_video, :fandub,
          url: 'http://online.animedia.tv/embed/14678/1/8',
          anime: anime
      end
      let!(:video_sublitles) { create :anime_video, :subtitles, anime: anime }

      it do
        is_expected.to eq(
          'озвучка' => [video_vk, video_other],
          'субтитры' => [video_sublitles]
        )
      end
    end

    context 'unknown grouped with fandub' do
      let!(:video_unknown) do
        create :anime_video, :unknown,
          url: 'http://online.animedia.tv/embed/14678/1/8',
          anime: anime
      end
      let!(:video_vk_fandub) do
        create :anime_video, :fandub,
          url: attributes_for(:anime_video)[:url],
          anime: anime
      end

      it do
        is_expected.to have(1).item
        expect(subject['озвучка']).to eq [video_vk_fandub, video_unknown]
      end
    end
  end

  describe '#all_kind?' do
    before do
      allow(player.h).to receive(:current_user).and_return user
      allow(player.h).to receive(:can?).and_return true
    end

    subject { player.all_kind? }

    context 'no videos' do
      it { is_expected.to eq false }
    end

    context 'one kind' do
      let!(:video_1) do
        create :anime_video, :fandub,
          url: 'http://online.animedia.tv/embed/14678/1/8',
          anime: anime
      end
      let!(:video_2) do
        create :anime_video, :fandub,
          url: attributes_for(:anime_video)[:url],
          anime: anime
      end

      it { is_expected.to eq false }

      context 'one is broken' do
        let!(:video_2) do
          create :anime_video, :fandub, :broken,
            url: attributes_for(:anime_video)[:url],
            anime: anime
        end
        it { is_expected.to eq true }
      end

      context 'all are broken' do
        let!(:video_1) do
          create :anime_video, :fandub, :broken,
            url: 'http://online.animedia.tv/embed/14678/1/8',
            anime: anime
        end
        let!(:video_2) do
          create :anime_video, :fandub, :broken,
            url: attributes_for(:anime_video)[:url],
            anime: anime
        end
        it { is_expected.to eq true }
      end
    end

    context 'two kinds' do
      let!(:video_1) do
        create :anime_video, :subtitles,
          url: 'http://online.animedia.tv/embed/14678/1/8',
          anime: anime
      end
      let!(:video_2) do
        create :anime_video, :fandub,
          url: attributes_for(:anime_video)[:url],
          anime: anime
      end

      it { is_expected.to eq true }

      context 'one is broken' do
        let!(:video_2) do
          create :anime_video, :fandub, :broken,
            url: attributes_for(:anime_video)[:url],
            anime: anime
        end
        it { is_expected.to eq true }
      end
    end
  end

  describe '#current_episode' do
    subject { player.current_episode }

    context 'not set' do
      it { is_expected.to eq 1 }
    end

    context 'set' do
      before do
        allow(player)
          .to receive_message_chain(:h, :params)
          .and_return episode: episode
      end

      context '0' do
        let(:episode) { 0 }
        it { is_expected.to eq 0 }
      end

      context '54' do
        let(:episode) { 54 }
        it { is_expected.to eq 54 }
      end

      context '9999999999999999' do
        let(:episode) { 9999999999999999 }
        it { is_expected.to eq 1 }
      end
    end
  end

  describe '#same_videos' do
    let(:anime) { create :anime }

    let!(:video_vk_1) do
      create :anime_video,
        url: attributes_for(:anime_video)[:url],
        anime: anime
    end
    let!(:video_vk_2) do
      create :anime_video,
        url: attributes_for(:anime_video)[:url] + 'a',
        anime: anime
    end
    let!(:video_other) do
      create :anime_video,
      url: 'http://online.animedia.tv/embed/14678/1/8',
      anime: anime
    end

    before { allow(player).to receive(:current_video).and_return video_vk_1.decorate }
    it { expect(player.same_videos).to have(2).items }
  end

  describe '#try_select_by' do
    subject { player.send :try_select_by, kind.to_s, language.to_s, hosting, author_id }
    let(:anime) { create :anime }

    context 'author_nil' do
      let(:kind) { :fandub }
      let(:language) { :russian }
      let(:hosting) { 'vk.com' }
      let(:author_id) { 1 }
      let!(:video) { create :anime_video, kind: kind, url: attributes_for(:anime_video)[:url], author: nil, anime: anime }
      it { is_expected.to eq video }
    end
  end

  # describe '#compatible?' do
    # subject { player.compatible?(video) }
    # let(:video) { build :anime_video, url: url }
    # let(:url) { 'http://rutube.ru?video=1' }
    # let(:h) { OpenStruct.new request: request, mobile?: is_mobile }
    # let(:request) { OpenStruct.new user_agent: user_agent }
    # let(:user_agent) { 'Mozilla/5.0 (Windows 2000; U) Opera 6.01 [en]' }
    # before { allow(player).to receive(:h).and_return h }

    # context 'desktop' do
      # let(:is_mobile) { false }
      # it { is_expected.to eq true }
    # end

    # context 'mobile' do
      # let(:is_mobile) { true }

      # context 'android' do
        # let(:user_agent) { 'Android' }
        # it { is_expected.to eq true }
      # end

      # context 'ios' do
        # let(:user_agent) { 'ios' }

        # context 'not allowed hostings' do
          # it { is_expected.to eq false }
        # end

        # context 'vk' do
          # let(:url) { 'http://vk.com?video=1' }
          # it { is_expected.to eq true }
        # end

        # context 'smotretanime' do
          # let(:url) { 'http://smotretanime.ru/translations/embed/960633' }
          # it { is_expected.to eq true }
        # end
      # end
    # end
  # end
end
