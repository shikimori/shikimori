describe Tags::CleanupTag do
  [
    'the sword art online',
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
    'sword art online!!',
    'sword_art_online amv',
    'sword_art_online episode 5'
  ].each do |tag|
    context tag do
      subject { described_class.instance.call tag }
      it { is_expected.to eq 'sword art online' }
    end
  end
end
