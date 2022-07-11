describe Tags::MatchDanbooruTags do
  let(:service) { described_class.new }

  let!(:anime_tag) { create :danbooru_tag, :copyright, name: 'naruto' }
  let!(:character_tag_1) { create :danbooru_tag, :character, ambiguous: false, name: 'naruto2' }
  let!(:character_tag_2) { create :danbooru_tag, :character, ambiguous: true, name: 'naruto3' }
  let!(:character_tag_3) { nil }

  let!(:anime) { create :anime, imageboard_tag: anime_tag.name }
  let!(:character) { create :character, name: character_tag_1.name }

  before { character.animes << anime }

  context 'charcter_tag for anime' do
    let!(:anime) { create :anime, name: character_tag_1.name }
    subject! { service.call }

    it { expect(anime.reload.imageboard_tag).to eq '' }
  end

  context 'charcter_tag for character' do
    subject! { service.call }

    context 'ambiguous' do
      let!(:character) { create :character, name: character_tag_2.name }
      it { expect(character.reload.imageboard_tag).to eq '' }
    end

    context 'not ambiguous' do
      it { expect(character.reload.imageboard_tag).to eq character_tag_1.name }
    end

    context 'tag with anime name' do
      let!(:character_tag_3) do
        create :danbooru_tag, :character,
          ambiguous: false,
          name: "#{character_tag_1.name}_(#{anime_tag.name})"
      end

      it { expect(character.reload.imageboard_tag).to eq character_tag_3.name }
    end
  end

  context 'anime tag for anime' do
    let!(:anime) { create :anime, name: anime_tag.name }
    subject! { service.call }

    it { expect(anime.reload.imageboard_tag).to eq anime_tag.name }
  end

  context 'anime tag for character' do
    let!(:character) { create :character, name: anime_tag.name }
    subject! { service.call }

    it { expect(character.reload.imageboard_tag).to eq '' }
  end
end
