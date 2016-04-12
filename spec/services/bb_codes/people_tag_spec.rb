describe BbCodes::PersonTag do
  let(:tag) { BbCodes::PersonTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:person) { create :person, id: 9876543, name: 'zxcvbn', russian: nil }

    let(:html) do
      <<-HTML.squish
<a href="//test.host/people/9876543-zxcvbn" title="zxcvbn"
class="bubbled b-link"
data-tooltip_url="//test.host/people/9876543-zxcvbn/tooltip">zxcvbn</a>
        HTML
    end

    let(:text) { "[person=#{person.id}]" }
    it { is_expected.to eq html }
  end
end
