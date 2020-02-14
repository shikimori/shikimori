describe Animes::Filters::Terms do
  subject { described_class.new value, dry_type }
  let(:value) { 'r,g,!r_plus' }

  context 'no dry_type' do
    let(:dry_type) { nil }

    it { is_expected.to have(3).items }
    its(:to_a) do
      is_expected.to eq [
        OpenStruct.new(value: 'r', is_negative: false),
        OpenStruct.new(value: 'g', is_negative: false),
        OpenStruct.new(value: 'r_plus', is_negative: true)
      ]
    end
    its(:positives) { is_expected.to eq %w[r g] }
    its(:negatives) { is_expected.to eq %w[r_plus] }
  end

  context 'dry_type' do
    let(:dry_type) { Types::Anime::Rating }

    it { is_expected.to have(3).items }
    its(:to_a) do
      is_expected.to eq [
        OpenStruct.new(value: Types::Anime::Rating[:r], is_negative: false),
        OpenStruct.new(value: Types::Anime::Rating[:g], is_negative: false),
        OpenStruct.new(value: Types::Anime::Rating[:r_plus], is_negative: true)
      ]
    end
    its(:positives) { is_expected.to eq %i[r g] }
    its(:negatives) { is_expected.to eq %i[r_plus] }
  end
end
