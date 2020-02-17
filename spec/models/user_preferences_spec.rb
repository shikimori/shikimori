describe UserPreferences do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:default_sort).is_at_most(255) }
    it do
      is_expected.to validate_numericality_of(:favorites_in_profile).is_greater_than_or_equal_to(0)
    end
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:list_privacy)
        .in(:public, :users, :friends, :owner)
        .with_default :public
    end
    it { is_expected.to enumerize(:body_width).in(:x1200, :x1000).with_default :x1200 }
    it do
      is_expected.to enumerize(:comment_policy).in(:users, :friends, :owner).with_default :users
    end
    it do
      is_expected.to enumerize(:default_sort).in(*Animes::Filters::OrderBy::Field.values)
    end
  end
end
