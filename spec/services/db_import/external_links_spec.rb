describe DbImport::ExternalLinks do
  let(:service) { DbImport::ExternalLinks.new target, external_links }
  let(:target) { create :anime }
  let(:external_links) do
    [{
      kind: 'official_site',
      url: 'http://www.cowboy-bebop.net/'
    }, {
      kind: 'anime_db',
      url: 'http://anidb.info/perl-bin/animedb.pl?show=anime&aid=23'
    }, {
      kind: 'anime_db',
      url: 'http://anidb.info/perl-bin/animedb.pl?show=anime&aid=23'
    }]
  end
  let!(:mal_external_link) { create :external_link, :myanimelist, :official_site, entry: target }
  let!(:shiki_external_link) { create :external_link, :shikimori, :official_site, entry: target }

  subject! { service.call }
  let(:new_external_links) { target.all_external_links.order :id }

  it do
    expect { mal_external_link.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(shiki_external_link.reload).to be_persisted

    expect(new_external_links).to have(3).items
    expect(new_external_links[0]).to eq shiki_external_link
    expect(new_external_links[1]).to have_attributes(
      entry: target,
      source: 'myanimelist',
      kind: 'official_site',
      url: 'http://www.cowboy-bebop.net/'
    )
    expect(new_external_links[2]).to have_attributes(
      entry: target,
      source: 'myanimelist',
      kind: 'anime_db',
      url: 'http://anidb.info/perl-bin/animedb.pl?show=anime&aid=23'
    )
  end
end
