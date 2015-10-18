describe CollectionMenu do
  let(:menu) { CollectionMenu.new Anime }

  describe '#sorted_genres' do
    before { menu.h.controller.request.env['warden'] ||= WardenStub.new }

    let!(:genre_1) { create :genre, position: 1, kind: :anime }
    let!(:genre_2) { create :genre, position: 2, kind: :anime }
    let!(:genre_3) { create :genre, position: 3, kind: :manga }

    it { expect(menu.sorted_genres).to eq [genre_1, genre_2] }
  end
end
