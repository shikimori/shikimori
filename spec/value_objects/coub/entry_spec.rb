describe Coub::Entry do
  subject(:coub) do
    Coub::Entry.new(
      permalink: 'zxc',
      image_template: 'z_%{version}_x',
      categories: categories,
      tags: tags,
      title: 'b',
      recoubed_permalink: recoubed_permalink,
      author: {
        permalink: 'n',
        name: 'm',
        avatar_template: 'a'
      },
      created_at: Time.zone.now.to_s
    )
  end
  let(:categories) { [] }
  let(:tags) { [] }
  let(:recoubed_permalink) { nil }

  describe '#anime?' do
    it { is_expected.to be_anime }

    context 'has non anime categories' do
      let(:categories) { %w[music] }
      it { is_expected.to_not be_anime }

      context 'has anime tag' do
        let(:tags) { [%w[anime zzz], %w[аниме xxx]].sample }
        it { is_expected.to be_anime }
      end
    end
  end

  describe '#recoubed?, #original_url' do
    context 'recoubed' do
      let(:recoubed_permalink) { 'qwe' }

      it { is_expected.to be_recoubed }
      it { expect(coub.original_url).to eq 'https://coub.com/view/qwe' }
    end

    context 'not recoubed' do
      let(:recoubed_permalink) { nil }

      it { is_expected.to be_recoubed }
      it { expect(coub.original_url).to be_nil }
    end
  end

  describe 'url' do
    it { expect(coub.url).to eq 'https://coub.com/view/zxc' }
  end

  describe 'player_url' do
    it do
      expect(coub.player_url).to eq(
        'https://coub.com/embed/zxc?autostart=true&startWithHD=true'
      )
    end
  end

  describe '#image_url' do
    it { expect(coub.image_url).to eq 'z_med_x' }
  end

  describe '#image_2x_url' do
    it { expect(coub.image_2x_url).to eq 'z_big_x' }
  end
end
