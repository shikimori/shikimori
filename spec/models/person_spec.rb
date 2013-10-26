
require 'spec_helper'

describe Person do
  context '#relations' do
    it { should have_many :person_roles }
    it { should have_many :animes }
    it { should have_many :mangas }
    it { should have_many :characters }

    it { should have_many :images }
    it { should have_attached_file :image }
  end
end
