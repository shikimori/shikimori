describe Characters::JobsWorker do
  let!(:character_1) { create :character }
  let!(:character_2) { create :character }
  let!(:character_3) { create :character }

  let!(:person_role_1_1) { create :person_role, character: character_1, anime: anime }
  let!(:person_role_1_2) { create :person_role, character: character_1, manga: manga }
  let!(:person_role_1_3) { create :person_role, character: character_1, manga: ranobe }
  let!(:person_role_2_1) { create :person_role, character: character_2, anime: anime }

  let(:anime) { create :anime }
  let(:manga) { create :manga }
  let(:ranobe) { create :ranobe }

  subject! { described_class.new.perform }

  it do
    expect(character_1.reload).to have_attributes(
      is_anime: true,
      is_manga: true,
      is_ranobe: true
    )
    expect(character_2.reload).to have_attributes(
      is_anime: true,
      is_manga: false,
      is_ranobe: false
    )
    expect(character_3.reload).to have_attributes(
      is_anime: false,
      is_manga: false,
      is_ranobe: false
    )
  end
end
