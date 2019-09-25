describe Api::V1::FavoritesController do
  include_context :authenticated, :user

  let(:method_name) { "fav_#{klass.name.downcase.pluralize}" }
  let(:entry) { create klass.name.downcase.to_sym }
  let(:kind) { Types::Favourite::Kinds[:producer] }

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
      expect(user.fav_producers).to include(entry)
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
      expect(user.reload.send(method_name)).not_to include(entry)
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

        if klass != Person
          context 'without kind' do
            let(:kind) { nil }
            it do
              expect { make_request }.to change(Favourite, :count).by(1)
              expect(user.send(method_name)).to include(entry)
            end
          end
        else
          context 'with kind' do
            it do
              expect { make_request }.to change(Favourite, :count).by(1)
              expect(user.fav_producers).to include(entry)
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
          expect(user.reload.send(method_name)).not_to include(entry)
        end
      end
    end
  end
end
