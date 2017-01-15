describe MalParsers::AnimeAuthorized do
  let(:parser) { MalParsers::AnimeAuthorized.new id }
  let(:id) { 11_757 }

  describe '#call', :vcr do
    subject { parser.call }

    it do
      is_expected.to eq(
        id: id,
        name: 'Sword Art Online',
        image: 'https://myanimelist.cdn-dena.com/images/anime/11/39717.jpg',
        english: 'Sword Art Online',
        synonyms: ['S.A.O', 'SAO'],
        japanese: 'ソードアート・オンライン',
        kind: :tv,
        episodes: 25,
        status: :released,
        aired_on: Date.parse('2012-07-08'),
        released_on: Date.parse('2012-12-23'),
        broadcast: 'Sundays at 00:00 (JST)',
        studios: [{ id: 56, name: 'A-1 Pictures' }],
        origin: :light_novel,
        genres: [
          {
            id: 1,
            name: 'Action'
          }, {
            id: 2,
            name: 'Adventure'
          }, {
            id: 10,
            name: 'Fantasy'
          }, {
            id: 11,
            name: 'Game'
          }, {
            id: 22,
            name: 'Romance'
          }
        ],
        duration: 23,
        rating: :pg_13,
        score: 7.83,
        ranked: 807,
        popularity: 3,
        members: 892_811,
        favorites: 40_900,
        related: {
          adaptation: [{
            id: 21_479,
            type: :manga,
            name: 'Sword Art Online'
          }, {
            id: 43_921,
            type: :manga,
            name: 'Sword Art Online: Progressive'
          }],
          other: [{
            id: 16_099,
            type: :anime,
            name: 'Sword Art Online: Sword Art Offline'
          }],
          sequel: [{
            id: 20_021,
            type: :anime,
            name: 'Sword Art Online: Extra Edition'
          }]
        },
        external_links: nil,
        synopsis: <<-TEXT.strip
          In the year 2022, virtual reality has progressed by leaps and bounds, and a massive online role-playing game called Sword Art Online (SAO) is launched. With the aid of "NerveGear" technology, players can control their avatars within the game using nothing but their own thoughts.\r\n\r\nKazuto Kirigaya, nicknamed "Kirito," is among the lucky few enthusiasts who get their hands on the first shipment of the game. He logs in to find himself, with ten-thousand others, in the scenic and elaborate world of Aincrad, one full of fantastic medieval weapons and gruesome monsters. However, in a cruel turn of events, the players soon realize they cannot log out; the game's creator has trapped them in his new world until they complete all one hundred levels of the game.\r\n\r\nIn order to escape Aincrad, Kirito will now have to interact and cooperate with his fellow players. Some are allies, while others are foes, like Asuna Yuuki, who commands the leading group attempting to escape from the ruthless game. To make matters worse, Sword Art Online is not all fun and games: if they die in Aincrad, they die in real life. Kirito must adapt to his new reality, fight for his survival, and hopefully break free from his virtual hell.\r\n\r\n[Written by MAL Rewrite]
        TEXT
      )
    end
  end
end
