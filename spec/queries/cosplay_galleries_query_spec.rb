describe CosplayGalleriesQuery do
  let(:query) { CosplayGalleriesQuery.new entry }
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

    describe 'by anime' do
      let(:entry) { anime }
      it { should eq [gallery_2, gallery_1] }
    end

    describe 'by manga' do
      let(:entry) { anime }
      let(:anime) { create :manga }
      let!(:person_role) { create :person_role, manga: anime, character: character }

      it { should eq [gallery_2, gallery_1] }
    end

    describe 'by character' do
      let(:entry) { character }
      it { should eq [gallery_2] }
    end
  end
end
