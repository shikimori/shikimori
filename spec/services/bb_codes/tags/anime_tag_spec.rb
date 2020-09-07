describe BbCodes::Tags::AnimeTag do
  subject { described_class.instance.format text }
  let(:anime) { create :anime, id: 9_876_543, name: 'test', russian: russian }

  let(:html) do
    <<~HTML.squish
      <a href="#{Shikimori::PROTOCOL}://test.host/animes/9876543-test" title="test" class="bubbled b-link"
      data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/animes/9876543-test/tooltip">#{name_html}</a>
    HTML
  end
  let(:name_html) { anime.name }
  let(:russian) { '' }

  context 'missing anime' do
    context 'without fallback' do
      let(:text) { '[anime=987654]' }
      it { is_expected.to eq "<span class='b-entry-404'><del>#{text}</del></span>" }
    end

    context 'with fallback' do
      let(:fallback) { 'http://ya.ru' }
      let(:text) { "[anime=987654 fallback=#{fallback}]" }
      it { is_expected.to eq fallback }
    end
  end

  context '[anime=id]' do
    let(:text) { "[anime=#{anime.id}]" }
    it { is_expected.to eq html }

    context 'bigint' do
      let(:text) { '[anime=111111111111111111111]' }
      it { is_expected.to eq "<span class='b-entry-404'><del>#{text}</del></span>" }
    end

    context 'fallback' do
      let(:fallback) { 'http://ya.ru' }
      let(:text) { "[anime=#{anime.id} fallback=zxc]" }

      it { is_expected.to eq html }

      context 'name' do
        let(:text) { "[anime=#{anime.id} fallback=zxc asdasdasd fg]" }
        it { is_expected.to eq html }
      end
    end

    context 'name' do
      let(:text) { "[anime=#{anime.id} asdasdasd-$#%^&*fg]" }
      it { is_expected.to eq html }
    end

    context 'multiple bb codes' do
      let(:anime2) { create :anime, id: 98_765_432, name: 'zxcvbn', russian: russian }
      let(:text) { "[anime=#{anime.id}][anime=#{anime2.id}]" }
      it do
        is_expected.to include html
        is_expected.to include anime.name
        is_expected.to include anime2.name
      end
    end

    context 'with russian name' do
      let(:name_html) do
        "<span class='name-en'>#{anime.name}</span>"\
          "<span class='name-ru' data-text='#{anime.russian}'></span>"
      end
      let(:russian) { 'test' }
      let(:text) { "[anime=#{anime.id}]" }

      it { is_expected.to eq html }
    end

    context 'with new lines or spaces text' do
      let(:text) { "[anime=#{anime.id}]#{suffix}" }
      let(:separator) { ["\n", ' '].sample }
      let(:suffix) { "#{separator}[/anime]" }
      it { is_expected.to eq html + suffix }
    end

    context 'broken tags' do
      let(:text) do
        "[anime=#{anime.id} fallback=http://shikimori.test/animes/32866]#{suffix}"
      end
      let(:suffix) { "\n[/anime][/quote]\n[/anime]" }
      it { is_expected.to eq html + suffix }
    end

    context 'tag after tag' do
      let(:text) { "[anime=#{anime.id}], [anime=#{anime.id}]z[/anime]" }
      it { is_expected.to_not include '[anime' }
    end
  end

  context '[anime]id[/anime]' do
    let(:text) { "[anime]#{anime.id}[/anime]" }
    it { is_expected.to eq html }
  end

  context '[anime=id]name[/anime]' do
    let(:russian) { 'тест' }

    context 'name equals anime.name' do
      let(:text) { "[anime=#{anime.id}]test[/anime]" }
      let(:name_html) do
        "<span class='name-en'>#{anime.name}</span>"\
          "<span class='name-ru' data-text='#{anime.russian}'></span>"
      end
      it { is_expected.to eq html }
    end

    context 'name not equals anime.name' do
      let(:text) { "[anime=#{anime.id}]test2[/anime]" }
      let(:name_html) { 'test2' }
      it { is_expected.to eq html }
    end
  end
end
