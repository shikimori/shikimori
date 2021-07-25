# frozen_string_literal: true

describe CosplayGallery do
  describe 'relations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many :image }
    it { is_expected.to have_many(:images).dependent :destroy }
    it { is_expected.to have_many :deleted_images }
    it { is_expected.to have_many(:links).dependent :destroy }
    it { is_expected.to have_many :cosplayers }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :characters }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:description).is_at_most(16384) }
    it { is_expected.to validate_length_of(:description_cos_rain).is_at_most(16384) }
  end

  it_behaves_like :topics_concern, :collection
end
