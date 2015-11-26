describe Mal::TextSanitizer do
  let(:parser) { Mal::TextSanitizer }

  subject { parser.call text }

  describe '#call' do
    describe '#cleanup' do
      describe '#specials' do
        it { expect(parser.call '&amp;').to eq '&' }
        it { expect(parser.call '&quot;').to eq '"' }
        it { expect(parser.call '&#039;').to eq "'" }
        it { expect(parser.call '&hellip;').to eq "…" }
      end

      context 'bad html' do
        it { expect(parser.call "<html><body><div>aaa").to eq '<div>aaa</div>' }
      end

      describe 'new lines' do
        it { expect(parser.call "a<br />\nb").to eq 'a[br]b' }
        it { expect(parser.call "a<br />\r\nb").to eq 'a[br]b' }
        it { expect(parser.call '<br>').to eq '' }
        it { expect(parser.call "\r\n").to eq '' }
        it { expect(parser.call 'a<br>a').to eq 'a[br]a' }
        it { expect(parser.call "a\r\na").to eq 'a[br]a' }
      end

      context 'tags' do
        context 'styled span' do
          let(:text) { "zzz<span style=\"font-size: 90%;\">xxx</span>" }
          it { is_expected.to eq 'zzzxxx' }
        end
      end

      context 'phrases' do
        context 'note' do
          let(:text) { "<br />\<b>Note:</b>zzz.<!--size--></span><br /><br />" }
          it { is_expected.to eq '' }
        end

        context 'no text' do
          let(:text) { "No synopsis information has been added to this title." }
          it { is_expected.to eq '' }
        end
      end
    end

    describe '#bb_codes' do
      it { expect(parser.call '<strong>a</strong>').to eq '[b]a[/b]' }
      it { expect(parser.call '<b>a</b>').to eq '[b]a[/b]' }
      it { expect(parser.call '<i>a</i>').to eq '[i]a[/i]' }
      it { expect(parser.call '<em>a</em>').to eq '[i]a[/i]' }
      it { expect(parser.call 'a<br>b').to eq 'a[br]b' }

      context '[anime]' do
        let(:text) { "<a href=\"http://myanimelist.net/anime.php?id=1\">zzz</a>" }
        it { is_expected.to eq '[anime=1]zzz[/anime]' }
      end

      context '[manga]' do
        let(:text) { "<a href=\"http://myanimelist.net/manga.php?id=1\">zzz</a>" }
        it { is_expected.to eq '[manga=1]zzz[/manga]' }
      end

      context '[character]' do
        let(:text) { "<a href=\"http://myanimelist.net/character/1/asd\">zzz</a>" }
        it { is_expected.to eq '[character=1]zzz[/character]' }
      end

      context '[person]' do
        let(:text) { "<a href=\"http://myanimelist.net/people/1/asd\">zzz</a>" }
        it { is_expected.to eq '[person=1]zzz[/person]' }
      end

      context '[center]' do
        let(:text) { "aaa <div style=\"text-align: center;\">ccc<!--center-->\n</div>bbb" }
        it { is_expected.to eq 'aaa [center]ccc[/center]bbb' }
      end

      context '[spoiler]' do
        let(:text) { "aaa <div class=\"spoiler\"><input type=\"button\" class=\"button\" onClick=\"this.nextSibling.nextSibling.style.display='inline-block';this.style.display='none';\" value=\"Show spoiler\"> <span class=\"spoiler_content\" style=\"display:none\"><input type=\"button\" class=\"button\" onClick=\"this.parentNode.style.display='none';this.parentNode.parentNode.childNodes[0].style.display='inline-block';\" value=\"Hide spoiler\"><br>ccc<!--spoiler--></span>\n</div><br />\nbbb" }
        it { is_expected.to eq 'aaa [br][spoiler][br]ccc[/spoiler][br]bbb' }
      end

      context '[source]' do
        let(:url) { 'http://onepiece.wikia.com/wiki/Shyarly' }

        context 'source link' do
          let(:text) { "aa\n\n(Source: <!--link--><a href=\"#{url}\">#{url}</a>)" }
          it { is_expected.to eq "aa[br][source]#{url}[/source]" }
        end

        context 'source link quoted' do
          let(:text) { "aa\n\n(Source: \"<!--link--><a href=\"#{url}\">#{url}</a>\")" }
          it { is_expected.to eq "aa[br][source]#{url}[/source]" }
        end

        context 'last link' do
          let(:text) { "aa\n\n(<!--link--><a href=\"#{url}\">#{url}</a>)" }
          it { is_expected.to eq "aa[br][source]#{url}[/source]" }
        end

        context 'last link with aftertext' do
          let(:text) { "aa\n\n<!--link--><a href=\"#{url}\">#{url}</a>fofofo" }
          it { is_expected.to eq "aa[br][source]#{url}[/source]" }
        end

        context 'broken link' do
          let(:text) { "aa\n\n(Source: <a href=\"#{url}\" target=\"_blank\"><a href=\"#{url}\" target=\"_blank\">#{url}</a></a>)" }
          it { is_expected.to eq "aa[br][source]#{url}[/source]" }
        end

        context 'source text' do
          let(:text) { "aa\n\n(Source: zxc)" }
          it { is_expected.to eq "aa[br][source]zxc[/source]" }
        end

        context 'source text quoted ' do
          let(:text) { "aa\n\n(Source: \"zxc\")" }
          it { is_expected.to eq "aa[br][source]zxc[/source]" }
        end
      end

      context '[img]' do
        let(:text) { "aa<img class=\"userimg\" data-src=\"http://static.tvtropes.org/pmwiki/pub/images/shirou_3881.png\">bb" }
        it { is_expected.to eq 'aa[img]http://static.tvtropes.org/pmwiki/pub/images/shirou_3881.png[/img]bb' }
      end

      context '[right]' do
        let(:text) { "aa<div style=\"text-align: right;\">ccc<!--right-->\n</div>bb" }
        it { is_expected.to eq 'aa[right]ccc[/right]bb' }
      end
    end

    describe '#comments' do
      it { expect(parser.call 'aaa<!-- bbb -->ccc').to eq "aaaccc" }
    end
  end
end
