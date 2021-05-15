describe BbCodes::Tags::AnimeTag do
  subject { described_class.instance.format text }
  let(:model) { create :anime, id: 9_876_543, name: 'test', russian: russian }
  let(:attrs) do
    {
      id: model.id,
      type: 'anime',
      name: model.name,
      russian: model.russian
    }
  end
  let(:url) { UrlGenerator.instance.anime_url model }
  let(:html) do
    <<~HTML.squish
      <a
        href='#{url}'
        title='#{model.name}'
        class='bubbled b-link'
        data-tooltip_url='#{url}/tooltip'
        data-attrs='#{ERB::Util.h attrs.to_json}'>#{name_html}</a>
    HTML
  end
  let(:name_html) { model.name }
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
    let(:text) { "[anime=#{model.id}]" }
    it { is_expected.to eq html }

    context 'bigint' do
      let(:text) { '[anime=111111111111111111111]' }
      it { is_expected.to eq "<span class='b-entry-404'><del>#{text}</del></span>" }
    end

    context 'fallback' do
      let(:fallback) { 'http://ya.ru' }
      let(:text) { "[anime=#{model.id} fallback=zxc]" }

      it { is_expected.to eq html }

      context 'name' do
        let(:text) { "[anime=#{model.id} fallback=zxc asdasdasd fg]" }
        it { is_expected.to eq html }
      end
    end

    context 'name' do
      let(:text) { "[anime=#{model.id} asdasdasd-$#%^&*fg]" }
      it { is_expected.to eq html }
    end

    context 'multiple bb codes' do
      let(:model_2) { create :anime, id: 98_765_432, name: 'zxcvbn', russian: russian }
      let(:text) { "[anime=#{model.id}][anime=#{model_2.id}]" }
      it do
        is_expected.to include html
        is_expected.to include model.name
        is_expected.to include model_2.name
      end
    end

    context 'with russian name' do
      let(:name_html) do
        "<span class='name-en'>#{model.name}</span>"\
          "<span class='name-ru'>#{model.russian}</span>"
      end
      let(:russian) { 'test' }
      let(:text) { "[anime=#{model.id}]" }

      it { is_expected.to eq html }
    end

    context 'with new lines or spaces text' do
      let(:text) { "[anime=#{model.id}]#{suffix}" }
      let(:separator) { ["\n", ' '].sample }
      let(:suffix) { "#{separator}[/anime]" }
      it { is_expected.to eq html + suffix }
    end

    context 'broken tags' do
      let(:text) do
        "[anime=#{model.id} fallback=http://shikimori.test/animes/32866]#{suffix}"
      end
      let(:suffix) { "\n[/anime][/quote]\n[/anime]" }
      it { is_expected.to eq html + suffix }
    end

    context 'tag after tag' do
      let(:text) { "[anime=#{model.id}], [anime=#{model.id}]z[/anime]" }
      it { is_expected.to_not include '[anime' }
    end
  end

  context '[anime]id[/anime]' do
    let(:text) { "[anime]#{model.id}[/anime]" }
    it { is_expected.to eq html }
  end

  context '[anime=id]name[/anime]' do
    let(:russian) { 'тест' }

    context 'name equals anime.name' do
      let(:text) { "[anime=#{model.id}]NOT XSS HERE\"'[/anime]" }
      # let(:name_html) do
      #   "<span class='name-en'>#{model.name}</span>"\
      #     "<span class='name-ru'>#{model.russian}</span>"
      # end
      let(:name_html) { "NOT XSS HERE\"'" }
      it { is_expected.to eq html }
    end

    context 'name not equals anime.name' do
      let(:text) { "[anime=#{model.id}]test2[/anime]" }
      let(:name_html) { 'test2' }
      it { is_expected.to eq html }
    end
  end
end
