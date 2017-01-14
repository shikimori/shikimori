describe Import::ExternalLinks do
  let(:service) { Import::ExternalLinks.new target, external_links }
  let(:target) { create :anime }
  let(:external_links) do
    [{
      source: 'official_site',
      url: 'http://www.cowboy-bebop.net/'
    }, {
      source: 'anime_db',
      url: 'http://anidb.info/perl-bin/animedb.pl?show=anime&aid=23'
    }]
  end
  let!(:external_link) do
    create :external_link,
      entry: target,
      source: 'official_site',
      url: 'http://lenta.ru'
  end

  subject! { service.call }
  let(:new_external_links) { target.external_links.order :id }

  it do
    expect(new_external_links).to have(2).items
    expect(new_external_links.first).to have_attributes(
      entry: target,
      source: 'official_site',
      url: 'http://lenta.ru'
    )
    expect(new_external_links.second).to have_attributes(
      entry: target,
      source: 'anime_db',
      url: 'http://anidb.info/perl-bin/animedb.pl?show=anime&aid=23'
    )
  end
end
