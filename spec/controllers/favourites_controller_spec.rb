describe FavouritesController do
  let(:user) { create :user }
  before { sign_in user }

  [Anime, Manga, Character, Person].each do |klass|
    describe klass do
      let(:entry) { create klass.name.downcase.to_sym }
      let(:method_name) { "fav_#{klass.name.downcase.pluralize}" }

      context 'POST create' do
        it 'success' do
          expect {
            post :create, linked_type: entry.class.name, linked_id: entry.id
          }.to change(Favourite, :count).by(1)
          user.send(method_name).should include(entry)
        end

        it 'supports kind parameter' do
          expect {
            post :create, linked_type: entry.class.name, linked_id: entry.id, kind: Favourite::Producer
          }.to change(Favourite, :count).by(1)
          user.fav_producers.should include(entry)
        end if klass == Person
      end

      context 'DELETE destroy' do
        let!(:favourite) { create :favourite, linked: entry, user: user }

        it 'success' do
          expect {
            delete :destroy, linked_type: entry.class.name, linked_id: entry.id
          }.to change(Favourite, :count).by -1
          user.reload.send(method_name).should_not include(entry)
        end
      end
    end
  end
end
