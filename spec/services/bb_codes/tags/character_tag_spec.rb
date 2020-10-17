describe BbCodes::Tags::CharacterTag do
  subject { described_class.instance.format text }
  let(:model) { create :character, id: 9876543, name: 'zxcvbn', russian: '' }
  let(:attrs) do
    {
      id: model.id,
      type: 'character',
      name: model.name,
      russian: model.russian
    }
  end
  let(:url) { UrlGenerator.instance.character_url model }

  let(:html) do
    <<-HTML.squish
      <a
        href='#{url}'
        title='#{model.name}'
        class='bubbled b-link'
        data-tooltip_url='#{url}/tooltip'
        data-attrs='#{attrs.to_json}'>#{model.name}</a>
    HTML
  end
  let(:text) { "[character=#{model.id}]" }

  it { is_expected.to eq html }
end
