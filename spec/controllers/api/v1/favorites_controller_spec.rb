describe Api::V1::FavoritesController do
  include_context :authenticated, :user

  let(:entry) { create klass.name.downcase.to_sym }
  let(:kind) { Types::Favourite::Kind[:producer] }

  describe '#create', :show_in_doc do
    let(:make_request) do
      post :create,
        params: {
          linked_type: entry.class.name,
          linked_id: entry.id,
          kind: kind
        }
    end
    let(:klass) { Person }

    it do
      expect { make_request }.to change(Favourite, :count).by(1)
      expect(user.favourites.map(&:linked)).to include(entry)
    end
  end

  describe '#destroy', :show_in_doc do
    let(:make_request) do
      delete :destroy,
        params: {
          linked_type: entry.class.name,
          linked_id: entry.id
        }
    end
    let!(:favourite) do
      create :favourite,
        linked_id: entry.id,
        linked_type: entry.class.name,
        user: user,
        kind: kind
    end
    let(:klass) { Person }

    it do
      expect { make_request }.to change(Favourite, :count).by(-1)
      expect(user.reload.favourites.map(&:linked)).not_to include(entry)
    end
  end

  describe '#reorder', :show_in_doc do
    let(:klass) { Anime }
    let(:entry_2) { create klass.name.downcase.to_sym }

    let!(:favourite_1) { create :favourite, linked: entry }
    let!(:favourite_2) { create :favourite, linked: entry_2, position: favourite_1.position + 1 }

    before do
      post :reorder,
        params: {
          id: favourite_2.id,
          new_index: new_index
        }
    end

    let(:new_index) { 0 }

    it do
      expect(favourite_1.reload).to be_last
      expect(favourite_2.reload).to be_first
      expect(response).to have_http_status :success
    end
  end

  [Anime, Manga, Character, Person, Ranobe].each do |klass|
    context klass.to_s do
      let(:klass) { klass }
      let(:entry) { create klass.name.downcase.to_sym }

      describe '#create' do
        let(:make_request) do
          post :create,
            params: {
              linked_type: entry.class.name,
              linked_id: entry.id,
              kind: kind
            }
        end

        if klass == Person
          context 'with kind' do
            it do
              expect { make_request }.to change(Favourite, :count).by(1)
              expect(user.favourites.map(&:linked)).to include(entry)
            end
          end
        else
          context 'without kind' do
            let(:kind) { nil }
            it do
              expect { make_request }.to change(Favourite, :count).by(1)
              expect(user.favourites.map(&:linked)).to include(entry)
            end
          end
        end
      end

      describe '#destroy' do
        let!(:favourite) do
          create :favourite,
            linked_id: entry.id,
            linked_type: entry.class.name,
            user: user,
            kind: kind
        end
        let(:make_request) do
          delete :destroy,
            params: {
              linked_type: entry.class.name,
              linked_id: entry.id
            }
        end

        it do
          expect { make_request }.to change(Favourite, :count).by(-1)
          expect(user.reload.favourites.map(&:linked)).not_to include(entry)
        end
      end
    end
  end
end
