describe BbCodes::Tags::MangaTag do
  let(:tag) { BbCodes::Tags::MangaTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:manga) { create :manga, id: 9876543, name: 'zxcvbn', russian: '' }

    let(:html) do
      <<-HTML.squish
        <a href="#{Shikimori::PROTOCOL}://test.host/mangas/9876543-zxcvbn" title="zxcvbn"
        class="bubbled b-link"
        data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/mangas/9876543-zxcvbn/tooltip">zxcvbn</a>
      HTML
    end

    let(:text) { "[manga=#{manga.id}]" }
    it { is_expected.to eq html }
  end
end
