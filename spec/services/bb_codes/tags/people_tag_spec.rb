describe BbCodes::Tags::PersonTag do
  subject { described_class.instance.format text }

  let(:model) { create :person, id: 9876543, name: 'zxcvbn', russian: '' }
  let(:attrs) do
    {
      id: model.id,
      type: 'person',
      name: model.name,
      russian: model.russian
    }
  end
  let(:url) { UrlGenerator.instance.person_url model }

  let(:html) do
    <<-HTML.squish
      <a
        href='#{url}'
        title='#{model.name}'
        class='bubbled b-link'
        data-tooltip_url='#{url}/tooltip'
        data-attrs='#{ERB::Util.h attrs.to_json}'>#{model.name}</a>
    HTML
  end
  let(:text) { "[person=#{model.id}]" }

  it { is_expected.to eq html }
end
