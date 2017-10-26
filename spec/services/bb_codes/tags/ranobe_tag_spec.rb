describe BbCodes::Tags::RanobeTag do
  let(:tag) { BbCodes::Tags::RanobeTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:ranobe) { create :ranobe, id: 9876543, name: 'zxcvbn', russian: nil }

    let(:html) do
      <<-HTML.squish
<a href="//test.host/ranobe/9876543-zxcvbn" title="zxcvbn"
class="bubbled b-link"
data-tooltip_url="//test.host/ranobe/9876543-zxcvbn/tooltip">zxcvbn</a>
        HTML
    end

    let(:text) { "[ranobe=#{ranobe.id}]" }
    it { is_expected.to eq html }
  end
end
