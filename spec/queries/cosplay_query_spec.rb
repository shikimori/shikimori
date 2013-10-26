require 'spec_helper'

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
    it { should have(3).items }
  end

  describe 'fetch' do
    let(:links) { CosplayGalleryLink.where(linked_type: Character.name).limit(2) }
    subject { CosplayQuery.new.fetch links }
    it { should have(2).items }
  end
end
