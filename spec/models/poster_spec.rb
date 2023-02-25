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

    describe '#cropped?' do
      subject { build :poster, crop_data: crop_data }

      context 'no crop_data' do
        let(:crop_data) { [nil, {}].sample }
        its(:cropped?) { is_expected.to eq false }
      end

      context 'has crop_data' do
        let(:crop_data) do
          {
            top: 0,
            left: 413,
            width: 510,
            height: 720
          }
        end
        its(:cropped?) { is_expected.to eq true }
      end
    end
  end
end
