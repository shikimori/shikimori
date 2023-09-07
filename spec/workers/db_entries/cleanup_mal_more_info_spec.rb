describe DbEntries::CleanupMalMoreInfo do
  let!(:anime_1) { create :anime, more_info: 'zxc' }
  let!(:anime_2) { create :anime, more_info: 'zxc [MAL]' }
  let!(:manga_1) { create :manga, more_info: 'zxc' }
  let!(:manga_2) { create :manga, more_info: '[MAL]' }

  subject! { described_class.new.perform }

  it do
    expect(anime_1.reload.more_info).to eq 'zxc'
    expect(anime_2.reload.more_info).to be_nil
    expect(manga_1.reload.more_info).to eq 'zxc'
    expect(manga_2.reload.more_info).to be_nil
  end
end
