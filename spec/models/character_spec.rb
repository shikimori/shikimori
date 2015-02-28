describe Character do
  it { should have_many :person_roles }
  it { should have_many :animes }
  it { should have_many :mangas }
  it { should have_many :persons }

  it { should have_many :persons }
  it { should have_many :japanese_roles }
  it { should have_many :seyu }

  it { should have_attached_file :image }

  it { should have_many :cosplay_gallery_links }
  it { should have_many :cosplay_galleries }
end
