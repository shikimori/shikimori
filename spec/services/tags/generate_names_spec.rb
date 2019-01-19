describe Tags::GenerateNames do
  subject { described_class.call names }

  context do
    let(:names) { ['sword_art_online - zxc', 'sword_art_online: zxc'].sample }
    it { is_expected.to eq ['sword art online zxc', 'sword art online'] }
  end

  context do
    let(:names) { 'sword art online' }
    it { is_expected.to eq ['sword art online'] }
  end

  context do
    let(:names) do
      [
        'sword art online',
        'Sword Art Online',
        'Sword Art Online season 2',
        'Sword Art Online s2',
        'Sword Art Online II',
        'Sword Art Online ova',
        'Sword Art Online TV',
        'Sword Art Online III',
        "Sword 'Art' Online",
        'Sword "Art" Online',
        'Sword_Art_Online',
        'sword_art_online',
        'sword art online!',
        'sword art online!!'
      ]
    end

    it { is_expected.to eq ['sword art online'] }
  end
end
