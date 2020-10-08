describe BbCodes::Text do
  let(:service) { described_class.new text }
  let(:text) { 'z' }

  describe '#call' do
    subject { service.call }

    describe '#cleanup' do
      describe 'smileys' do
        describe 'multiple with spaces' do
          let(:text) { ':):D:-D' }
          it do
            is_expected.to eq(
              '<img src="/images/smileys/:).gif" alt=":)" title=":)" class="smiley">'
            )
          end
        end

        describe 'multiline smileys' do
          let(:text) { "раз :D :D\nдва :D :D\nтри" }
          it do
            is_expected.to include 'раз'
            is_expected.to include 'два'
            is_expected.to include 'три'
          end
        end

        describe 'multiple' do
          let(:text) { ':):D :-D' }
          it { is_expected.to eq '<img src="/images/smileys/:).gif" alt=":)" title=":)" class="smiley">' }
        end

        describe 'different' do
          let(:text) { ':D:D:D:D:tea2:' }
          it { is_expected.to eq '<img src="/images/smileys/:D.gif" alt=":D" title=":D" class="smiley">' }
        end
      end

      describe '!!!!' do
        let(:text) { '!!!!' }
        it { is_expected.to eq '!' }
      end

      describe '???' do
        let(:text) { '???' }
        it { is_expected.to eq '?' }
      end

      describe '.....' do
        let(:text) { '.....' }
        it { is_expected.to eq '.' }
      end

      describe '))))))' do
        let(:text) { '))))))' }
        it { is_expected.to eq ')' }
      end

      describe '(((' do
        let(:text) { '(((' }
        it { is_expected.to eq '(' }
      end

      describe 'bad html' do
        let(:text) { '[quote][spoiler=qwe]test[/quote][/spoiler]' }
        it do
          is_expected.to eq(
            <<-HTML.squish
              <div class="b-quote"><div class="quote-content"><div
                class="b-spoiler_block to-process"
                data-dynamic="spoiler_block"><span tabindex="0">qwe</span><div>test</div></div></div></div>
            HTML
          )
        end
      end
    end

    describe '[wall]' do
      let(:text) { '[wall][/wall]' }
      it { is_expected.to eq '<div class="b-shiki_wall to-process" data-dynamic="wall"></div>' }
    end

    describe '[vkontakte]', :vcr do
      let(:text) { 'http://vk.com/video98023184_165811692' }
      it { is_expected.to include '<div class="c-video b-video unprocessed vk' }
    end

    describe '[youtube]', :vcr do
      context 'direct link' do
        let(:text) { 'https://www.youtube.com/watch?v=og2a5lngYeQ' }
        it { is_expected.to include '<div class="c-video b-video unprocessed youtube' }
      end

      context 'link with &' do
        let(:text) { 'https://www.youtube.com/watch?feature=player_embedded&v=aX9j5KokIeE' }
        it { is_expected.to include '<div class="c-video b-video unprocessed youtube' }
      end
    end

    describe '[url]' do
      context 'example 1' do
        let(:text) { 'http://www.small-games.info' }
        it do
          is_expected.to eq(
            '<a class="b-link" href="http://www.small-games.info" rel="noopener noreferrer nofollow">www.small-games.info</a>'
          )
        end
      end

      context 'example 2' do
        let(:text) { '[url=http://www.small-games.info]www.small-games.info[/url]' }
        it do
          is_expected.to eq(
            '<a class="b-link" href="http://www.small-games.info" rel="noopener noreferrer nofollow">www.small-games.info</a>'
          )
        end
      end
    end

    describe 'db_entry_url_tag -> db_entry_tag' do
      let!(:anime) { create :anime, id: 9_876_543, name: 'z' }
      let(:text) { 'http://shikimori.local/animes/9876543-test' }
      it do
        is_expected.to include(
          "<a href=\"#{anime.decorate.url}\" title=\"#{anime.name}\" "\
            'class="bubbled b-link"'
        )
      end
    end

    describe '[mention]' do
      let(:text) { '[mention=1]test[/mention]' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href="#{Shikimori::PROTOCOL}://shikimori.test/test"
            class="b-mention"><s>@</s><span>test</span></a>
          HTML
        )
      end
    end

    describe '[div]' do
      let(:text) { '[div=zz]test[/div]' }
      it { is_expected.to eq '<div class="zz" data-div="">test</div>' }
    end

    describe '[hr]' do
      let(:text) { '[hr]' }
      it { is_expected.to eq '<hr>' }
    end

    describe '[br]' do
      let(:text) { '[br]' }
      it { is_expected.to eq '<br>' }
    end

    describe '[p]' do
      let(:text) { '[p]test[/p]' }
      it { is_expected.to eq '<div class="b-prgrph">test</div>' }
    end

    describe '[image]' do
      let(:text) { "[image=#{user_image.id}]" }
      let(:user_image) { create :user_image, user: build_stubbed(:user) }
      it do
        is_expected.to eq(
          <<-HTML.squish.strip
            <a
              href="#{user_image.image.url :original, false}"
              rel="#{XXhash.xxh32 text, 0}"
              class="b-image unprocessed"><img
                src="#{user_image.image.url :thumbnail, false}"
                data-width="#{user_image.width}"
                data-height="#{user_image.height}"
                loading="lazy"><span class="marker">1000x1000</span></a>
          HTML
        )
      end
    end

    describe '[img]' do
      let(:url) { 'http://site.com/image.jpg' }
      let(:text) { "[img]#{url}[/img]" }
      it { is_expected.to include 'class="b-image unprocessed"' }
    end

    describe '[poster]' do
      let(:url) { 'http://site.com/image.jpg' }
      let(:text) { "[poster]#{url}[/poster]" }
      let(:camo_url) { UrlGenerator.instance.camo_url url }
      it do
        expect(camo_url).to include '?url=http%3A%2F%2Fsite.com%2Fimage.jpg'
        is_expected.to eq(
          "<span class=\"b-image b-poster no-zoom\"><img src=\"#{camo_url}\" loading=\"lazy\"></span>"
        )
      end
    end

    describe '[entries]' do
      let(:character) { create :character }
      let(:text) { "[characters ids=#{character.id}]" }
      it { is_expected.to include 'b-catalog_entry' }
    end

    describe '[spoiler=text]' do
      let(:text) { '[spoiler=1]test[/spoiler]' }
      it { is_expected.to_not include '[spoiler' }
    end

    describe 'spam domains' do
      let(:text) { ['http://images.webpark.ru', 'http://shikme.ru'].sample }
      it { is_expected.to eq BbCodes::Text::BANNED_TEXT }
    end

    describe '[b]' do
      let(:text) { '[b]test[/b]' }
      it { is_expected.to eq '<strong>test</strong>' }
    end

    describe '[i]' do
      let(:text) { '[i]test[/i]' }
      it { is_expected.to eq '<em>test</em>' }
    end

    describe '[u]' do
      let(:text) { '[u]test[/u]' }
      it { is_expected.to eq '<u>test</u>' }
    end

    describe '[s]' do
      let(:text) { '[s]test[/s]' }
      it { is_expected.to eq '<del>test</del>' }
    end

    describe '[size]' do
      let(:text) { '[size=13]test[/size]' }
      it { is_expected.to eq '<span style="font-size: 13px;">test</span>' }
    end

    describe '[center]' do
      let(:text) { '[center]test[/center]' }
      it { is_expected.to eq '<center>test</center>' }
    end

    describe '[right]' do
      let(:text) { '[right]test[/right]' }
      it { is_expected.to eq '<div class="right-text">test</div>' }
    end

    describe '[solid]' do
      let(:text) { '[solid]test[/solid]' }
      it { is_expected.to eq '<div class="solid">test</div>' }
    end

    describe '[color]' do
      let(:text) { '[color=red]test[/color]' }
      it { is_expected.to eq '<span style="color: red;">test</span>' }
    end

    describe '[url]' do
      let(:text) { '[url]http://test.com[/url]' }
      it do
        is_expected.to eq(
          '<a class="b-link" href="http://test.com" rel="noopener noreferrer nofollow">test.com</a>'
        )
      end
    end

    describe '[list]' do
      let(:text) { '[list][*]первая строка[*]вторая строка[/list]' }
      it { is_expected.to eq '<ul class="b-list"><li>первая строка</li><li>вторая строка</li></ul>' }
    end

    describe '[h3]' do
      let(:text) { '[h3]test[/h3]' }
      it { is_expected.to eq '<h3>test</h3>' }
    end

    describe '[replies]' do
      let(:text) { "[replies=#{comment.id}]" }
      let!(:comment) { create :comment }
      it do
        is_expected.to include '<div class="b-replies translated-before single"'
        is_expected.to_not include '[/comment]'
      end
    end

    describe '[contest_round]' do
      let(:text) { "[contest_round_status=#{round.id} finished]" }
      let!(:round) { create :contest_round, number: 1, additional: false }
      it { is_expected.to include round.title }
    end

    describe '[contest]' do
      let(:text) { "[contest_status=#{contest.id} finished]" }
      let!(:contest) { create :contest }
      it { is_expected.to include contest.name }
    end

    describe '[html5_video]' do
      let(:text) { "[html5_video]#{url}[/html5_video]" }
      let(:url) { 'http://html5demos.com/assets/dizzy.webm' }

      it { is_expected.to include "data-video=\"#{url}\"" }
    end

    describe '[quote]' do
      context 'simple' do
        let(:text) { '[quote]test[/quote]zz' }
        it do
          is_expected.to eq(
            '<div class="b-quote"><div class="quote-content">test</div></div>zz'
          )
        end
      end

      context 'comment quote' do
        let(:text) { "[quote=#{attrs}]test[/quote]" }
        let(:attrs) { "c#{comment.id};#{user.id};zz" }
        let(:comment) { create :comment, user: user }

        it do
          is_expected.to_not include '[quote='
          is_expected.to_not include '[comment='
          is_expected.to include(
            '<div class="b-quote" data-attrs="' + attrs + '">'
          )
        end
      end

      context 'simple with \\n before' do
        let(:text) { "[quote]\ntest[/quote]zz" }
        it do
          is_expected.to eq(
            '<div class="b-quote"><div class="quote-content">test</div></div>zz'
          )
        end
      end

      context 'simple with \\n after' do
        let(:text) { '[quote]test[/quote]\nzz' }
        it do
          is_expected.to eq(
            '<div class="b-quote"><div class="quote-content">test</div></div>\nzz'
          )
        end
      end

      context 'link inside with space' do
        let(:text) { '[quote] http://test.ru/ [/quote]\ntest' }
        it do
          is_expected.to eq(
            '<div class="b-quote"><div class="quote-content"> <a class="b-link" href="http://test.ru/" rel="noopener noreferrer nofollow">test.ru/</a> </div></div>\ntest'
          )
        end
      end

      context 'link inside w/o space' do
        let(:text) { '[quote] http://test.ru/[/quote]\ntest' }
        it do
          is_expected.to eq(
            '<div class="b-quote"><div class="quote-content"> <a class="b-link" href="http://test.ru/" rel="noopener noreferrer nofollow">test.ru/</a></div></div>\ntest'
          )
        end
      end
    end

    describe '[code]' do
      let(:text) { '[code] [b]test[/b] [/code]' }
      it do
        is_expected.to include '[b]test[/b]'
        is_expected.to include '<pre class="b-code-v2 to-process" data-dynamic="code_highlight"'
      end
    end

    describe 'russian link' do
      let(:text) { 'http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/' }
      it do
        is_expected.to eq(
          '<a class="b-link" href="http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/" rel="noopener noreferrer nofollow">www.hentasis.com</a>'
        )
      end
    end

    describe 'obsolete tags' do
      context 'user_change' do
        let(:text) { 'test [user_change=93904]правка[/user_change] test' }
        it { is_expected.to eq 'test правка test' }
      end
    end

    describe 'cleanup new lines' do
      let(:text) do
        "[quote]\n\n[quote]\n\ntest\n\n[/quote]\n\n[/quote]\n\n"\
          "[div]\n\ntest\n\n[/div]"
      end
      it do
        # is_expected.to eq(
        #   <<~HTML.squish
        #     <div class="b-quote"><div class="quote-content"><br><div
        #       class="b-quote"><div
        #       class="quote-content"><br>test<br></div></div><br></div></div><br><div data-div=""><br>test<br></div>
        #   HTML
        # )
        is_expected.to eq(
          <<~HTML.squish
            <div class="b-quote"><div class="quote-content"><br><div
              class="b-quote"><div
              class="quote-content"><br>test<br></div></div></div></div><br><div data-div=""><br>test<br></div>
          HTML
        )
      end
    end
  end

  describe '#remove_old_tags' do
    subject { service.remove_old_tags text }

    describe '<p>' do
      let(:text) { "<p>\t\n\rTest.</p>\n<p>Zxc</p>" }
      it { is_expected.to eq "Test.\nZxc" }
    end

    describe '&lt;p&gt;' do
      let(:text) { "<p>\t\n\rTest.</p>\n&lt;p&gt;Zxc&lt;/p&gt;" }
      it { is_expected.to eq "Test.\nZxc" }
    end

    describe '<br>' do
      let(:text) { '123<br />456<br>789' }
      it { is_expected.to eq "123\n456\n789" }
    end

    describe '&lt;br&gt;' do
      let(:text) { '123&lt;br /&gt;456&lt;br/&gt;789' }
      it { is_expected.to eq "123\n456\n789" }
    end

    describe 'trail \n' do
      let(:text) { "123\n456\n789\n\n" }
      it { is_expected.to eq "123\n456\n789" }
    end
  end

  describe '#prepare' do
    let(:text) { " z\r\n\nx " }
    subject { service.send :prepare, text }
    it { is_expected.to eq "z\n\nx" }
  end
end
