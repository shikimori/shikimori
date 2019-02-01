describe AnimeVideoDecorator, type: :controller do
  subject(:decorator) { AnimeVideoDecorator.new video }
  let(:video) { build :anime_video }

  describe '#player_html' do
    subject { decorator.player_html }

    let(:video) { build :anime_video }
    let(:fixed_url) { Url.new(url).without_protocol }

    before { video[:url] = url }

    context 'mp4 html 5' do
      let(:url) { 'http://online.animaunt.ru/Anime%20Online/All%20Anime/%5BAniMaunt.Ru%5D%20JoJo%E2%80%99s%20Bizarre%20Adventure/jojo1.01.mp4' }
      it do
        is_expected.to eq <<-HTML.squish
          <video src="#{fixed_url}" controls="controls"></video>
        HTML
      end
    end

    context 'myvi.ru' do
      context 'embeded' do
        let(:url) { 'http://myvi.ru/player/embed/html/ol6hiPjFZDkw26HMFBhPTi8IXSDbsARIEybMzKjm6MbKQZ44GQmiStIBzPFxWba-80' }
        it do
          is_expected.to eq <<-HTML.squish
            <iframe src="#{fixed_url}" frameborder="0"
              webkitAllowFullScreen="true" mozallowfullscreen="true"
              scrolling="no" allowfullscreen="allowfullscreen"></iframe>
          HTML
        end
      end

      context 'flash' do
        let(:url) { 'http://myvi.ru/player/flash/o_qym5zt9aPeL9mvSKMfUTRY4FGD0JHrHX6yr_dznWK0yDZy3cUQYVqgAkSbPgJmr0' }
        it do
          is_expected.to eq <<-HTML.squish
            <object><param name="movie"
              value="#{fixed_url}"></param><param
              name="allowFullScreen" value="true"></param><param
              name="allowScriptAccess" value="always"></param><embed
              src="#{fixed_url}"
              type="application/x-shockwave-flash"
              allowfullscreen="allowfullscreen"
              allowScriptAccess="always"></embed></object>
          HTML
        end
      end
    end

    context 'sibnet.ru' do
      context 'with .swf?' do
        let(:url) { 'http://sibnet.ru/video/1.swf?' }
        it do
          is_expected.to eq <<-HTML.squish
            <object><param name="movie"
              value="#{fixed_url}"></param><param
              name="allowFullScreen" value="true"></param><param
              name="allowScriptAccess" value="always"></param><embed
              src="#{fixed_url}"
              type="application/x-shockwave-flash"
              allowfullscreen="allowfullscreen"
              allowScriptAccess="always"></embed></object>
          HTML
        end
      end

      context 'without .swf?' do
        let(:url) { 'http://sibnet.ru/video/1' }
        it do
          is_expected.to eq <<-HTML.squish
            <iframe src="#{fixed_url}" frameborder="0"
              webkitAllowFullScreen="true" mozallowfullscreen="true"
              scrolling="no" allowfullscreen="allowfullscreen"></iframe>
          HTML
        end
      end
    end

    context 'vk' do
      let(:url) { 'http://www.vk.com?id=1' }
      it do
        is_expected.to eq <<-HTML.squish
          <iframe src="#{fixed_url}" frameborder="0"
            webkitAllowFullScreen="true" mozallowfullscreen="true" scrolling="no"
            allowfullscreen="allowfullscreen"></iframe>
        HTML
      end
    end

    # context 'rutube.ru' do
    #   context 'http://video.rutube.ru/7632871' do
    #     let(:url) { 'http://video.rutube.ru/7632871' }
    #     let(:expected_url) { '//rutube.ru/play/embed/7632871' }
    #     it do
    #       is_expected.to eq <<-HTML.squish
    #         <iframe src="#{expected_url}" frameborder="0"
    #           webkitAllowFullScreen="true" mozallowfullscreen="true"
    #           scrolling="no" allowfullscreen="allowfullscreen"></iframe>
    #       HTML
    #     end
    #   end

    #   context 'http://rutube.ru/play/embed/7630847' do
    #     let(:url) { 'http://rutube.ru/play/embed/7630847' }
    #     it do
    #       is_expected.to eq <<-HTML.squish
    #         <iframe src="#{fixed_url}" frameborder="0"
    #           webkitAllowFullScreen="true" mozallowfullscreen="true"
    #           scrolling="no" allowfullscreen="allowfullscreen"></iframe>
    #       HTML
    #     end
    #   end

    #   context 'http://video.rutube.ru/4f4dbbd7882342b057b4c387097e491e' do
    #     let(:url) { 'http://video.rutube.ru/4f4dbbd7882342b057b4c387097e491e' }
    #     let(:expected_url) { '//rutube.ru/player.swf?hash=4f4dbbd7882342b057b4c387097e491e' }
    #     it do
    #       is_expected.to eq <<-HTML.squish
    #         <object><param name="movie"
    #           value="#{expected_url}"></param><param name="allowFullScreen"
    #           value="true"></param><param name="allowScriptAccess"
    #           value="always"></param><embed src="#{expected_url}"
    #           type="application/x-shockwave-flash"
    #           allowfullscreen="allowfullscreen"
    #           allowScriptAccess="always"></embed></object>
    #       HTML
    #     end
    #   end
    # end

    context 'youtube.ru' do
      context 'Fix fullscreen for https://www.youtube.com/embed/q89fWhsD5z8' do
        let(:url) { 'https://www.youtube.com/embed/q89fWhsD5z8' }
        it do
          is_expected.to eq <<-HTML.squish
            <iframe src="#{fixed_url}" frameborder="0"
              webkitAllowFullScreen="true" mozallowfullscreen="true"
              scrolling="no" allowfullscreen="allowfullscreen"></iframe>
          HTML
        end
      end
    end
  end

  describe '#player_url' do
    subject { decorator.player_url }
    let(:video) { create :anime_video, url: url }
    let(:url) { attributes_for(:anime_video)[:url] }

    it { is_expected.to eq url }
  end

  describe '#user_rate & #in_list? & #watched?' do
    before { allow(decorator).to receive(:h).and_return auth_double }
    let(:auth_double) { double current_user: user, user_signed_in?: user_signed_in }

    context 'authenticated' do
      let(:user_signed_in) { true }

      context 'with user rate' do
        let!(:user_rate) do
          create :user_rate,
            target: video.anime,
            user: user,
            episodes: episodes
        end
        let(:episodes) { 99 }

        its(:user_rate) { is_expected.to eq user_rate }
        its(:in_list?) { is_expected.to eq true }

        context 'watched episode' do
          its(:watched?) { is_expected.to eq true }
        end

        context 'not watched episode' do
          let(:episodes) { 0 }
          its(:watched?) { is_expected.to eq false }
        end
      end

      context 'without user rate' do
        its(:user_rate) { is_expected.to be_nil }
        its(:in_list?) { is_expected.to eq false }
        its(:watched?) { is_expected.to eq false }
      end
    end

    context 'not authenticated' do
      let(:user) { nil }
      let(:user_signed_in) { false }

      its(:user_rate) { is_expected.to be_nil }
      its(:in_list?) { is_expected.to eq false }
      its(:watched?) { is_expected.to eq false }
    end
  end
end
