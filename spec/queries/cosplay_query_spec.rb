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

  describe '#characters' do
    subject { CosplayQuery.new.characters anime }
    it { expect(subject).to have(3).items }
  end

  describe '#fetch' do
    let(:links) { CosplayGalleryLink.where(linked_type: Character.name).limit(2) }
    subject { CosplayQuery.new.fetch links }
    it { expect(subject).to have(2).items }
  end
end
