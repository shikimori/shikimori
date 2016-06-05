describe FavouritesController do
  include_context :authenticated, :user

  [Anime, Manga, Character, Person].each do |klass|
    context klass.to_s do
      let(:entry) { create klass.name.downcase.to_sym }
      let(:method_name) { "fav_#{klass.name.downcase.pluralize}" }

      describe '#create' do
        let(:make_request) do
          post :create, linked_type: entry.class.name, linked_id: entry.id, kind: kind
        end

        context 'withput kind' do
          let(:kind) { nil }
          it do
            expect { make_request }.to change(Favourite, :count).by(1)
            expect(user.send(method_name)).to include(entry)
          end
        end

        context 'with kind' do
          let(:kind) { Favourite::Producer }
          it do
            expect { make_request }.to change(Favourite, :count).by(1)
            expect(user.fav_producers).to include(entry)
          end
        end if klass == Person
      end

      describe '#destroy' do
        let!(:favourite) { create :favourite, linked: entry, user: user }
        let(:make_request) do
          delete :destroy, linked_type: entry.class.name, linked_id: entry.id
        end

        it 'success' do
          expect { make_request }.to change(Favourite, :count).by(-1)
          expect(user.reload.send(method_name)).not_to include(entry)
        end
      end
    end
  end
end
