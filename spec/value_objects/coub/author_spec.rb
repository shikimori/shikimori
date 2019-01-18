describe Coub::Author do
  subject(:author) do
    Coub::Author.new(
      permalink: 'zxc',
      avatar_template: 'z_%{version}_x',
      name: 'b'
    )
  end

  describe 'url' do
    it { expect(author.url).to eq 'https://coub.com/zxc' }
  end

  describe '#avatar_url' do
    it { expect(author.avatar_url).to eq 'z_medium_x' }
  end

  describe '#avatar_2x_url' do
    it { expect(author.avatar_2x_url).to eq 'z_medium_2x_x' }
  end
end
