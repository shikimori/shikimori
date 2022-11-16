describe Poster do
  describe 'relations' do
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
    it { is_expected.to belong_to(:character).optional }
    it { is_expected.to belong_to(:person).optional }
  end

  describe 'instance method' do
    describe '#magnificable?' do
      subject { build :poster, image_data: image_data }

      context 'no image' do
        let(:image_data) { [nil, {}].sample }
        its(:magnificable?) { is_expected.to eq false }
      end

      context 'has image' do
        let(:image_data) { { 'metadata' => { 'width' => width } } }

        context 'narrow image' do
          let(:width) { described_class::WIDTH }
          its(:magnificable?) { is_expected.to eq false }
        end

        context 'wide image' do
          let(:width) { described_class::WIDTH + 1 }
          its(:magnificable?) { is_expected.to eq true }
        end
      end
    end
  end
end
