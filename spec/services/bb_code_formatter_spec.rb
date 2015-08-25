describe BbCodeFormatter do
  let(:processor) { BbCodeFormatter.instance }

  it '#remove_wiki_codes' do
    expect(processor.remove_wiki_codes("[[test]]")).to eq "test"
    expect(processor.remove_wiki_codes("[[test|123]]")).to eq "123"
  end

  describe '#format_description' do
    subject { processor.format_description text, anime }
    let(:anime) { build :anime }

    describe '[spoiler] with [b]' do
      let(:text) { "[spoiler=[b]z[/b]]x[/spoiler]" }
      it { should_not include "<br" }
    end
  end

  describe '#paragraphs' do
    subject { processor.paragraphs text }
    let(:long_line) { 'x' * BbCodeFormatter::MIN_PARAGRAPH_SIZE }

    describe '\n' do
      let(:text) { "#{long_line}1\n#{long_line}2\n333" }
      it { should eq "[p]#{long_line}1[/p][p]#{long_line}2[/p]333" }
    end

    describe '<br>' do
      let(:text) { "#{long_line}1<br>#{long_line}2<br />333" }
      it { should eq "[p]#{long_line}1[/p][p]#{long_line}2[/p]333" }
    end

    describe '&lt;br&gt;' do
      let(:text) { "#{long_line}1&lt;br&gt;#{long_line}2&lt;br/&gt;333" }
      it { should eq "[p]#{long_line}1[/p][p]#{long_line}2[/p]333" }
    end

    describe '[*]' do
      let(:text) { "[list]\n [*]#{long_line}\r\n[/list]" }
      it { should eq "[list]\n [*]#{long_line}\r\n[/list]" }
    end

    describe '[quote]' do
      let(:text) { "[quote]zzz" }
      it { should eq "[quote]\nzzz" }
    end
  end

  describe '#user_mention' do
    let!(:user) { create :user, nickname: 'test' }
    subject { processor.user_mention text }

    describe 'just mention' do
      let(:text) { '@test, hello' }
      it { should eq "[mention=#{user.id}]#{user.nickname}[/mention], hello" }
    end

    describe 'mention with period' do
      let(:text) { '@test.' }
      it { should eq "[mention=#{user.id}]#{user.nickname}[/mention]." }
    end
    describe 'mention w/o comma' do
      let(:text) { '@test test test' }
      it { should eq "[mention=#{user.id}]#{user.nickname}[/mention] test test" }
    end

    describe 'two mentions' do
      let(:text) { '@test, @test' }
      it { should eq "[mention=#{user.id}]#{user.nickname}[/mention], [mention=#{user.id}]#{user.nickname}[/mention]" }
    end
  end

  describe '#db_entry_mention' do
    subject { processor.db_entry_mention text }

    describe 'english' do
      context 'anime' do
        let(:anime) { create :anime, name: "Hayate no Gotoku! Can't Take My Eyes Off You" }
        let(:text) { "[Hayate no Gotoku! Can&#x27;t Take My Eyes Off You]" }
        it { should eq "[anime=#{anime.id}]#{anime.name}[/anime]" }

        context 'score order' do
          let!(:anime) { create :anime, name: 'test', score: 5 }
          let!(:anime2) { create :anime, name: 'test', score: 9 }
          let(:text) { "[#{anime.name}]" }
          it { should eq "[anime=#{anime2.id}]#{anime.name}[/anime]" }
        end
      end

      context 'manga' do
        let(:manga) { create :manga }
        let(:text) { "[#{manga.name}]" }
        it { should eq "[manga=#{manga.id}]#{manga.name}[/manga]" }
      end

      context 'character' do
        let(:character) { create :character }
        let(:text) { "[#{character.name}]" }
        it { should eq "[character=#{character.id}]#{character.name}[/character]" }

        context 'reversed name' do
          let(:text) { "[#{character.name.split(' ').reverse.join ' '}]" }
          it { should eq "[character=#{character.id}]#{character.name.split(' ').reverse.join ' '}[/character]" }
        end
      end

      context 'person' do
        let(:person) { create :person }
        let(:text) { "[#{person.name}]" }
        it { should eq "[person=#{person.id}]#{person.name}[/person]" }
      end
    end

    describe 'russian' do
      context 'anime' do
        let(:anime) { create :anime, russian: 'руру' }
        let(:text) { "[#{anime.russian}]" }
        it { should eq "[anime=#{anime.id}]#{anime.russian}[/anime]" }
      end

      context 'manga' do
        let(:manga) { create :manga, russian: 'руру' }
        let(:text) { "[#{manga.russian}]" }
        it { should eq "[manga=#{manga.id}]#{manga.russian}[/manga]" }
      end

      context 'character' do
        let(:character) { create :character, russian: 'руру' }
        let(:text) { "[#{character.russian}]" }
        it { should eq "[character=#{character.id}]#{character.russian}[/character]" }
      end
    end

    context 'no match' do
      let(:text) { "[test]" }
      it { should eq "[test]" }
    end
  end

  describe '#remove_old_tags' do
    subject { processor.remove_old_tags text }

    describe '<p>' do
      let(:text) { "<p>\t\n\rTest.</p>\n<p>Zxc</p>" }
      it { should eq "Test.\nZxc" }
    end

    describe '&lt;p&gt;' do
      let(:text) { "<p>\t\n\rTest.</p>\n&lt;p&gt;Zxc&lt;/p&gt;" }
      it { should eq "Test.\nZxc" }
    end

    describe '<br>' do
      let(:text) { "123<br />456<br>789" }
      it { should eq "123\n456\n789" }
    end

    describe '&lt;br&gt;' do
      let(:text) { "123&lt;br /&gt;456&lt;br/&gt;789" }
      it { should eq "123\n456\n789" }
    end

    describe 'trail \n' do
      let(:text) { "123\n456\n789\n\n" }
      it { should eq "123\n456\n789" }
    end
  end

  describe '#format_comment' do
    subject { processor.format_comment text }

    describe '#cleanup' do
      describe 'smileys' do
        describe 'multiple with spaces' do
          let(:text) { ":):D:-D" }
          it { should eq "<img src=\"/images/smileys/:).gif\" alt=\":)\" title=\":)\" class=\"smiley\">" }
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
          let(:text) { ":):D :-D" }
          it { should eq "<img src=\"/images/smileys/:).gif\" alt=\":)\" title=\":)\" class=\"smiley\">" }
        end

        describe 'different' do
          let(:text) { ':D:D:D:D:tea2:' }
          it { should eq '<img src="/images/smileys/:D.gif" alt=":D" title=":D" class="smiley">' }
        end
      end

      describe '!!!!' do
        let(:text) { '!!!!' }
        it { should eq '!' }
      end

      describe '???' do
        let(:text) { '???' }
        it { should eq '?' }
      end

      describe '.....' do
        let(:text) { '.....' }
        it { should eq '.' }
      end

      describe '))))))' do
        let(:text) { '))))))' }
        it { should eq ')' }
      end

      describe '(((' do
        let(:text) { '(((' }
        it { should eq '(' }
      end

      describe 'bad html' do
        let(:text) { '[quote][spoiler]test[/quote][/spoiler]' }
        it { should eq '<div class="b-quote"><div class="b-spoiler unprocessed"><label>спойлер</label><div class="content"><div class="before"></div><div class="inner">test</div></div><div class="after"></div></div></div>' }
      end
    end

    describe '[wall]' do
      let(:text) { '[wall][/wall]' }
      it { should eq '<div class="b-shiki_wall unprocessed"></div>' }
    end

    describe '[vkontakte]', vcr: { cassette_name: 'bb_code_formatter' } do
      let(:text) { "http://vk.com/video98023184_165811692" }
      it { should include '<a class="c-video b-video unprocessed vk' }
    end

    describe '[youtube]', vcr: { cassette_name: 'bb_code_formatter' } do
      context 'direct link' do
        let(:text) { "https://www.youtube.com/watch?v=og2a5lngYeQ" }
        it { should include '<a class="c-video b-video unprocessed youtube' }
      end

      context 'link with &' do
        let(:text) { "https://www.youtube.com/watch?feature=player_embedded&v=aX9j5KokIeE" }
        it { should include '<a class="c-video b-video unprocessed youtube' }
      end
    end

    describe '[url]' do
      let(:text) { '[url=http://www.small-games.info]www.small-games.info[/url]' }
      it { should eq '<a class="b-link" href="http://www.small-games.info">www.small-games.info</a>' }
    end

    describe '[mention]' do
      let(:text) { '[mention=1]test[/mention]' }
      it { should eq '<a href="http://shikimori.org/test" class="b-mention"><s>@</s><span>test</span></a>' }
    end

    describe '[hr]' do
      let(:text) { '[hr]' }
      it { should eq '<hr>' }
    end

    describe '[p]' do
      let(:text) { '[p]test[/p]' }
      it { should eq '<div class="prgrph">test</div>' }
    end

    describe '[image]' do
      let(:text) { "[image=#{user_image.id}]" }
      let(:user_image) { create :user_image, user: build_stubbed(:user) }
      it { should eq "<a href=\"#{user_image.image.url :original}\" \
rel=\"#{XXhash.xxh32 text, 0}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :thumbnail}\" class=\"\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\">\
<span class=\"marker\">1000x1000</span>\
</a>" }
    end

    describe '[img]' do
      let(:url) { 'http://site.com/image.jpg' }
      let(:text) { "[img]#{url}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{XXhash.xxh32 text, 0}\" class=\"b-image unprocessed\">\
<img src=\"#{url}\" class=\"check-width\"></a>" }
    end

    describe '[poster]' do
      let(:url) { 'http://site.com/image.jpg' }
      let(:text) { "[poster]#{url}[/poster]" }
      it { should eq "<img class=\"b-poster\" src=\"#{url}\">" }
    end

    describe '[entries]' do
      let(:character) { create :character }
      let(:text) { "[characters ids=#{character.id}]" }
      it { should include "b-catalog_entry" }
    end

    describe '[spoiler=text]' do
      let(:text) { '[spoiler=1]test[/spoiler]' }
      it { should_not include '[spoiler' }
    end

    describe '[spoiler]' do
      let(:text) { '[spoiler]test[/spoiler]' }
      it { should_not include '[spoiler' }
    end

    describe 'nested [spoiler]' do
      let(:text) { '[spoiler=test] [spoiler=1]test[/spoiler][/spoiler]' }
      it { should_not include '[spoiler' }
    end

    describe 'malware domains' do
      let(:text) { 'http://images.webpark.ru' }
      it { should eq 'malware.domain' }
    end

    describe '[b]' do
      let(:text) { '[b]test[/b]' }
      it { should eq '<strong>test</strong>' }
    end

    describe '[i]' do
      let(:text) { '[i]test[/i]' }
      it { should eq '<em>test</em>' }
    end

    describe '[u]' do
      let(:text) { '[u]test[/u]' }
      it { should eq '<span style="text-decoration: underline;">test</span>' }
    end

    describe '[s]' do
      let(:text) { '[s]test[/s]' }
      it { should eq '<del>test</del>' }
    end

    describe '[size]' do
      let(:text) { '[size=13]test[/size]' }
      it { should eq '<span style="font-size: 13px;">test</span>' }
    end

    describe '[center]' do
      let(:text) { '[center]test[/center]' }
      it { should eq '<center>test</center>' }
    end

    describe '[right]' do
      let(:text) { '[right]test[/right]' }
      it { should eq '<div class="right-text">test</div>' }
    end

    describe '[solid]' do
      let(:text) { '[solid]test[/solid]' }
      it { should eq '<div class="solid">test</div>' }
    end

    describe '[color]' do
      let(:text) { '[color=red]test[/color]' }
      it { should eq '<span style="color: red;">test</span>' }
    end

    describe '[url]' do
      let(:text) { '[url]http://test.com[/url]' }
      it { should eq '<a class="b-link" href="http://test.com">test.com</a>' }
    end

    describe '[list]' do
      let(:text) { '[list][*]первая строка[*]вторая строка[/list]' }
      it { should eq '<ul class="b-list"><li>первая строка</li><li>вторая строка</li></ul>' }
    end

    describe '[h3]' do
      let(:text) { '[h3]test[/h3]' }
      it { should eq '<h3>test</h3>' }
    end

    describe '[replies]' do
      let(:text) { "[replies=#{comment.id}]" }
      let!(:comment) { create :comment }
      it { should include "<div class=\"b-replies single\"" }
    end

    describe '[contest_round]' do
      let(:text) { "[contest_round=#{round.id}]" }
      let!(:round) { create :contest_round }
      it { should include "Раунд ##{round.id}" }
    end

    describe '[quote]' do
      context 'simple' do
        let(:text) { '[quote]test[/quote]zz' }
        it { should eq '<div class="b-quote">test</div>zz' }
      end

      context 'simple with \\n before' do
        let(:text) { "[quote]\ntest[/quote]zz" }
        it { should eq '<div class="b-quote">test</div>zz' }
      end

      context 'simple with \\n after' do
        let(:text) { '[quote]test[/quote]\nzz' }
        it { should eq '<div class="b-quote">test</div>\nzz' }
      end

      context 'link inside with space' do
        let(:text) { '[quote] http://test.ru/ [/quote]\ntest' }
        it { should eq '<div class="b-quote"> <a class="b-link" href="http://test.ru/">test.ru/</a> </div>\ntest' }
      end

      context 'link inside w/o space' do
        let(:text) { '[quote] http://test.ru/[/quote]\ntest' }
        it { should eq '<div class="b-quote"> <a class="b-link" href="http://test.ru/">test.ru/</a></div>\ntest' }
      end
    end

    describe 'russian link' do
      let(:text) { 'http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/' }
      it { should eq '<a class="b-link" href="http://www.hentasis.com/tags/%D3%F7%E8%F2%E5%EB%FC%ED%E8%F6%FB/">www.hentasis.com</a>' }
    end

    describe 'two replies' do
      let(:text) { '[comment=1260072]Viks[/comment],
[comment=1260062]Егор Кун[/comment],' }
      it { should eq '<span class="bubbled" data-href="http://shikimori.org/comments/1260072.html">Viks</span>,<br><span class="bubbled" data-href="http://shikimori.org/comments/1260062.html">Егор Кун</span>,' }
    end
  end
end
