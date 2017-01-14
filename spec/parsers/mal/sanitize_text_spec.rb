describe Mal::SanitizeText do
  let(:parser) { described_class }

  subject { parser.call text }

  describe '#call' do
    describe '#cleanup' do
      describe '#specials' do
        it { expect(parser.call '&amp;').to eq '&' }
        it { expect(parser.call '&quot;').to eq '"' }
        it { expect(parser.call '&#039;').to eq "'" }
        it { expect(parser.call '&hellip;').to eq '…' }
      end

      context '#fix_html' do
        it { expect(parser.call '<html><body><div>aaa').to eq '<div>aaa</div>' }
      end

      describe '#fix_new_lines' do
        it { expect(parser.call "a<br />\nb").to eq 'a[br]b' }
        it { expect(parser.call "a<br />\r\nb").to eq 'a[br]b' }
        it { expect(parser.call '<br>').to eq '' }
        it { expect(parser.call "\r\n").to eq '' }
        it { expect(parser.call 'a<br>a').to eq 'a[br]a' }
        it { expect(parser.call "a\r\na").to eq 'a[br]a' }
      end

      context '#fix_tags' do
        context 'styled span' do
          let(:text) { 'zzz<span style="font-size: 90%;">xxx</span>' }
          it { is_expected.to eq 'zzzxxx' }
        end
      end

      context '#fix_phrases' do
        context 'note' do
          let(:text) { '<br /><b>Note:</b>zzz.<!--size--></span><br /><br />' }
          it { is_expected.to eq '' }
        end

        context 'no text' do
          let(:text) { 'No synopsis information has been added to this title.' }
          it { is_expected.to eq '' }
        end
      end

      context '#fix_links' do
        context 'moreinfo #1' do
          let(:text) { '<a href="http://myanimelist.net/z/-/moreinfo">x</a>' }
          it { is_expected.to eq 'x' }
        end

        context 'moreinfo #2' do
          let(:text) { '<a href="http://myanimelist.net/z/-/moreinfo/">x</a>' }
          it { is_expected.to eq 'x' }
        end

        context 'double link' do
          let(:url) { 'http://www.mangareader.net/1368/tenchi-souzou.html' }
          let(:text) { "<a href=\"#{url}\" target=\"_blank\" rel=\"nofollow\"></a><a href=\"#{url}\" target=\"_blank\" rel=\"nofollow\">#{url}</a>" }
          it { is_expected.to eq "[url=#{url}]#{url}[/url]" }
        end
      end
    end

    describe '#bb_codes' do
      it { expect(parser.call '<strong>a</strong>').to eq '[b]a[/b]' }
      it { expect(parser.call '<b>a</b>').to eq '[b]a[/b]' }
      it { expect(parser.call '<i>a</i>').to eq '[i]a[/i]' }
      it { expect(parser.call '<em>a</em>').to eq '[i]a[/i]' }
      it { expect(parser.call 'a<br>b').to eq 'a[br]b' }

      context 'complex' do
        let(:text) { "<!--link--><a href=\"http://myanimelist.net/manga/12073\">Kinpeibai Kinden Honoo no Kuchizuke</a>.\n\n(Source: MU)" }
        it { is_expected.to eq '[manga=12073]Kinpeibai Kinden Honoo no Kuchizuke[/manga].[source]MU[/source]' }
      end

      context '[anime] #1' do
        let(:text) { '<a href="http://myanimelist.net/anime.php?id=1">zzz</a>' }
        it { is_expected.to eq '[anime=1]zzz[/anime]' }
      end

      context '[anime] #2' do
        let(:text) { '<a href="http://myanimelist.net/anime/3449/">zzz</a>' }
        it { is_expected.to eq '[anime=3449]zzz[/anime]' }
      end

      context '[anime] #3' do
        let(:text) { '<a href="http://myanimelist.net/anime/3449/qwSw-_:test!123">zzz</a>' }
        it { is_expected.to eq '[anime=3449]zzz[/anime]' }
      end

      context '[anime] #4' do
        let(:text) { '<a href="http://myanimelist.net/anime/3449"><i>zzz</i></a>' }
        it { is_expected.to eq '[anime=3449]zzz[/anime]' }
      end

      context '[anime] with nofollow' do
        let(:text) { '<a href="http://myanimelist.net/anime.php?id=1" rel="nofollow">zzz</a>' }
        it { is_expected.to eq '[anime=1]zzz[/anime]' }
      end

      context '[manga]' do
        let(:text) { '<a href="http://myanimelist.net/manga.php?id=1">zzz</a>' }
        it { is_expected.to eq '[manga=1]zzz[/manga]' }
      end

      context '[character]' do
        let(:text) { '<a href="http://myanimelist.net/character/1/asd">zzz</a>' }
        it { is_expected.to eq '[character=1]zzz[/character]' }
      end

      context '[person]' do
        let(:text) { '<a href="http://myanimelist.net/people/1/asd">zzz</a>' }
        it { is_expected.to eq '[person=1]zzz[/person]' }
      end

      context '[center]' do
        let(:text) { "aaa <div style=\"text-align: center;\">ccc<!--center-->\n</div>bbb" }
        it { is_expected.to eq 'aaa [center]ccc[/center]bbb' }
      end

      context '[spoiler]' do
        let(:spoiler_open) { "<div class=\"spoiler\">\n<input type=\"button\" class=\"button show_button\" onclick=\"this.nextSibling.style.display='inline-block';this.style.display='none';\" data-showname=\"Show spoiler\" data-hidename=\"Hide spoiler\" value=\"Show spoiler\"><span class=\"spoiler_content\" style=\"display:none\"><input type=\"button\" class=\"button hide_button\" onclick=\"this.parentNode.style.display='none';this.parentNode.parentNode.childNodes[0].style.display='inline-block';\" value=\"Hide spoiler blabla v2.0\"><br>" }
        let(:spoiler_close) { "</span>\n</div>" }

        context 'old' do
          let(:text) { "aaa <div class=\"spoiler\"><input type=\"button\" class=\"button\" onClick=\"this.nextSibling.nextSibling.style.display='inline-block';this.style.display='none';\" value=\"Show spoiler\"> <span class=\"spoiler_content\" style=\"display:none\"><input type=\"button\" class=\"button\" onClick=\"this.parentNode.style.display='none';this.parentNode.parentNode.childNodes[0].style.display='inline-block';\" value=\"Hide spoiler\"><br>ccc<!--spoiler--></span>\n</div><br />\nbbb" }
          it { is_expected.to eq 'aaa [br][spoiler][br]ccc[/spoiler][br]bbb' }
        end

        context 'new' do
          let(:text) { "aaa #{spoiler_open}ccc#{spoiler_close}<br />\nbbb" }
          it { is_expected.to eq 'aaa [br][spoiler][br]ccc[/spoiler][br]bbb' }
        end

        context 'nested spoilers' do
          let(:text) { "aaa #{spoiler_open}bbb#{spoiler_open}ccc#{spoiler_close}ddd#{spoiler_close}eee" }
          it { is_expected.to eq 'aaa [br][spoiler][br]bbb[br][spoiler][br]ccc[/spoiler]ddd[/spoiler]eee' }
        end
      end

      context '[source]' do
        let(:url) { 'http://onepiece.wikia.com/wiki/Shyarly' }

        context 'source on first line' do
          let(:text) { "aa<a href=\"#{url}\">#{url}</a>" }
          it { is_expected.to eq "aa[url=#{url}]#{url}[/url]" }
        end

        context 'source on first with long text' do
          let(:text) { "#{'a' * 301}<a href=\"#{url}\">#{url}</a>" }
          it { is_expected.to eq "#{'a' * 301}[source]#{url}[/source]" }
        end

        context 'source link' do
          let(:text) { "aa\n\n(Source: <!--link--><a href=\"#{url}\">#{url}</a>)" }
          it { is_expected.to eq "aa[source]#{url}[/source]" }
        end

        context 'source link quoted' do
          let(:text) { "aa\n\n(Source: \"<!--link--><a href=\"#{url}\">#{url}</a>\")" }
          it { is_expected.to eq "aa[source]#{url}[/source]" }
        end

        context 'last link' do
          let(:text) { "aa\n\n(<!--link--><a href=\"#{url}\">#{url}</a>)" }
          it { is_expected.to eq "aa[source]#{url}[/source]" }
        end

        context 'last link with aftertext' do
          let(:text) { "aa\n\n<!--link--><a href=\"#{url}\">#{url}</a>fofofo" }
          it { is_expected.to eq "aa[source]#{url}[/source]" }
        end

        context 'broken link' do
          let(:text) { "aa\n\n(Source: <a href=\"#{url}\" target=\"_blank\"><a href=\"#{url}\" target=\"_blank\">#{url}</a></a>)" }
          it { is_expected.to eq "aa[source]#{url}[/source]" }
        end

        context 'source text' do
          let(:text) { "aa\n\n(Source: zxc)" }
          it { is_expected.to eq 'aa[source]zxc[/source]' }
        end

        context 'source text quoted' do
          let(:text) { "aa\n\n(Source: \"zxc\")" }
          it { is_expected.to eq 'aa[source]zxc[/source]' }
        end

        context 'source in <b>' do
          let(:text) { "aa\n<b>Source:</b> Mellow Candle" }
          it { is_expected.to eq 'aa[source]Mellow Candle[/source]' }
        end

        context 'source in <div>' do
          let(:text) { '<div style="text-align: right;">(source: arago.wikia.com)</div>' }
          it { is_expected.to eq '[source]arago.wikia.com[/source]' }
        end

        context 'Written by MAL Rewrite' do
          let(:text) { "Test.\r\n\r\n[Written by MAL Rewrite]" }
          it { is_expected.to eq 'Test.' }
        end
      end

      context 'other tags' do
        context '[img] #1' do
          let(:text) { 'aa<img class="userimg" data-src="http://static.tvtropes.org/pmwiki/pub/images/shirou_3881.png">bb' }
          it { is_expected.to eq 'aa[img]http://static.tvtropes.org/pmwiki/pub/images/shirou_3881.png[/img]bb' }
        end

        context '[img] #2' do
          let(:text) { 'aa<img class="userimg" src="http://static.tvtropes.org/pmwiki/pub/images/shirou_3881.png">bb' }
          it { is_expected.to eq 'aa[img]http://static.tvtropes.org/pmwiki/pub/images/shirou_3881.png[/img]bb' }
        end

        context '[right]' do
          let(:text) { "aa<div style=\"text-align: right;\">ccc<!--right-->\n</div>bb" }
          it { is_expected.to eq 'aa[right]ccc[/right]bb' }
        end

        context '[center]' do
          let(:text) { "aa<div style=\"text-align: right;\">ccc<!--right-->\n</div>bb" }
          it { is_expected.to eq 'aa[right]ccc[/right]bb' }
        end

        context '[link]' do
          let(:name) { 'test' }
          let(:text) { "<a href=\"#{url}\">#{name}</a>\nzxc" }

          context 'unknown domain' do
            let(:url) { 'http://test.com' }
            it { is_expected.to eq "[url=#{url}]#{name}[/url][br]zxc" }
          end

          context 'myanimelist.net' do
            let(:url) { 'http://myanimelist.net' }
            it { is_expected.to eq "<a href=\"#{url}\">#{name}</a>[br]zxc" }
          end
        end
      end
    end

    describe '#comments' do
      it { expect(parser.call 'aaa<!-- bbb -->ccc').to eq 'aaaccc' }
    end

    describe '#finalize' do
      it { expect(parser.call "\n test \n").to eq 'test' }
    end
  end
end
