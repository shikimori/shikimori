describe BbCodes::AnimeTag do
  let(:tag) { BbCodes::AnimeTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:anime) { create :anime, id: 9876543, name: 'zxcvbn', russian: russian }

    let(:html) do
      <<-HTML.squish
<a href="//test.host/animes/9876543-zxcvbn" title="zxcvbn"
class="bubbled b-link"
data-tooltip_url="//test.host/animes/9876543-zxcvbn/tooltip">#{name_html}</a>
        HTML
    end
    let(:name_html) { anime.name }
    let(:russian) { nil }

    context 'missing anime' do
      let(:text) { "[anime=987654]" }
      it { is_expected.to eq text }
    end

    context '[anime=id]' do
      let(:text) { "[anime=#{anime.id}]" }
      it { is_expected.to eq html }

      context 'multiple bb codes' do
        let(:anime2) { create :anime, id: 98765432, name: 'zxcvbn', russian: russian }
        let(:text) { "[anime=#{anime.id}][anime=#{anime2.id}]" }
        it do
          is_expected.to include html
          is_expected.to include anime.name
          is_expected.to include anime2.name
        end
      end

      context 'with russian name' do
        let(:name_html) do
          <<-HTML.squish
<span class="en-name">#{anime.name}</span><span
class="ru-name" data-text="#{anime.russian}"></span>
          HTML
        end
        let(:russian) { 'test' }
        let(:text) { "[anime=#{anime.id}]" }

        it { is_expected.to eq html }
      end
    end

    context '[anime]id[/anime]' do
      let(:text) { "[anime]#{anime.id}[/anime]" }
      it { is_expected.to eq html }
    end

    context '[anime=id]name[/anime]' do
      let(:text) { "[anime=#{anime.id}]test[/anime]" }
      let(:name_html) { 'test' }
      it { is_expected.to eq html }
    end
  end
end
