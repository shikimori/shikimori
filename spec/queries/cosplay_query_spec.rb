describe CosplayQuery do
  let(:characters) { [create(:character), create(:character), create(:character)] }
  let(:anime) { create :anime, characters: characters }

  before do
    characters.each do |character|
      create :cosplay_gallery, links: [
          create(:cosplay_gallery_link, linked: character),
          create(:cosplay_gallery_link, linked: create(:cosplayer))
        ]
    end
  end

  describe 'characters' do
    subject { CosplayQuery.new.characters anime }
    it 'has 3 items' do
      expect(subject.size).to eq(3)
    end
  end

  describe 'fetch' do
    let(:links) { CosplayGalleryLink.where(linked_type: Character.name).limit(2) }
    subject { CosplayQuery.new.fetch links }
    it 'has 2 items' do
      expect(subject.size).to eq(2)
    end
  end
end
