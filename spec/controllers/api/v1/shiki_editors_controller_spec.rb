describe Api::V1::ShikiEditorsController do
  describe '#show' do
    subject! do
      get :show,
        params: {
          anime: [anime.id].join(','),
          manga: [manga_1.id, manga_2.id].join(','),
          character: [character.id].join(','),
          person: [person.id].join(','),
          user_image: [user_image.id].join(',')
        }
    end
    let(:anime) { create :anime }
    let(:manga_1) { create :manga }
    let(:manga_2) { create :ranobe }
    let(:character) { create :character }
    let(:person) { create :person }
    let(:user_image) { create :user_image }

    it do
      expect(json).to eq(
        anime: [{
          'id' => anime.id,
          'text' => anime.russian,
          'url' => "/animes/#{anime.to_param}"
        }],
        manga: [{
          'id' => manga_1.id,
          'text' => manga_1.russian,
          'url' => "/mangas/#{manga_1.to_param}"
        }, {
          'id' => manga_2.id,
          'text' => manga_2.russian,
          'url' => "/ranobe/#{manga_2.to_param}"
        }],
        character: [{
          'id' => character.id,
          'text' => character.russian,
          'url' => "/characters/#{character.to_param}"
        }],
        person: [{
          'id' => person.id,
          'text' => person.russian,
          'url' => "/people/#{person.to_param}"
        }],
        user_image: [
          {
            'id' => user_image.id,
            'url' => ImageUrlGenerator.instance.url(user_image, :original)
            # 'original_url' => user_image.image.url(:original),
            # 'preview_url' => user_image.image.url(:preview),
            # 'width' => user_image.width,
            # 'height' => user_image.height
          }
        ]
      )
    end
  end
end
