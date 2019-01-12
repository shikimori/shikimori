describe Tags::MatchCoubTags do
  let!(:anime_1) { create :anime, name: 'qqq', coub_tag: 'zxc' }
  let!(:anime_2) { create :anime, name: 'qqq', coub_tag: nil }
  let!(:anime_3) { create :anime, name: 'www', coub_tag: nil }

  subject! { described_class.call %w[zxc qqq] }

  it do
    expect(anime_1.reload.coub_tag).to eq 'zxc'
    expect(anime_2.reload.coub_tag).to eq 'qqq'
    expect(anime_3.reload.coub_tag).to be_nil
  end
end
