describe Coub::Author do
  subject(:entry) do
    Coub::Author.new(
      permalink: 'zxc',
      avatar_template: 'z_%{version}_x',
      name: 'b'
    )
  end

  describe '#avatar_url' do
    it { expect(entry.avatar_url).to eq 'z_profile_pic_new_x' }
  end

  describe '#avatar_2x_url' do
    it { expect(entry.avatar_2x_url).to eq 'z_profile_pic_new_2x_x' }
  end
end
