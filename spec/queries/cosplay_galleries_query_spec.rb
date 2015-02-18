describe CosplayGalleriesQuery do
  let(:query) { CosplayGalleriesQuery.new anime }
  let(:anime) { create :anime }
  let(:character) { create :character }
  let!(:person_role) { create :person_role, anime: anime, character: character }

  describe '#fetch' do
    let(:gallery_1) { create :cosplay_gallery, created_at: 2.days.ago }
    let(:gallery_2) { create :cosplay_gallery, created_at: 1.day.ago }
    let(:gallery_3) { create :cosplay_gallery }
    let(:gallery_4) { create :cosplay_gallery, created_at: 1.day.ago, confirmed: false }
    let!(:link_1) { create :cosplay_gallery_link, cosplay_gallery: gallery_1, linked: anime }
    let!(:link_2) { create :cosplay_gallery_link, cosplay_gallery: gallery_2, linked: character }
    let!(:link_4) { create :cosplay_gallery_link, cosplay_gallery: gallery_4, linked: character }

    subject { query.fetch 1, 10 }
    it { should eq [gallery_2, gallery_1] }
  end
end
