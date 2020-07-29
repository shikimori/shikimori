describe BbCodes::Tags::PersonTag do
  subject { described_class.instance.format text }

  let(:person) { create :person, id: 9876543, name: 'zxcvbn', russian: '' }
  let(:html) do
    <<-HTML.squish
      <a href="#{Shikimori::PROTOCOL}://test.host/people/9876543-zxcvbn" title="zxcvbn"
      class="bubbled b-link"
      data-tooltip_url="#{Shikimori::PROTOCOL}://test.host/people/9876543-zxcvbn/tooltip">zxcvbn</a>
    HTML
  end
  let(:text) { "[person=#{person.id}]" }

  it { is_expected.to eq html }
end
