class OauthApplication < Doorkeeper::Application
  belongs_to :owner, polymorphic: true
  has_many :user_rate_logs, dependent: :destroy

  DEFAULT_SCOPES = %w[
    user_rates
  ]
  TEST_APP_ID = 15

  attribute :allowed_scopes, :string,
    array: true,
    default: %w[user_rates comments topics]

  has_attached_file :image,
    styles: {
      x320: ['320x320#', :png],
      x160: ['160x160#', :png],
      x96: ['96x96#', :png],
      x48: ['48x48#', :png]
    },
    url: '/system/application/:style/:id.:extension',
    path: ':rails_root/public/system/application/:style/:id.:extension',
    default_url: '/assets/globals/missing_:style_:style.png'

  validates :image, attachment_content_type: { content_type: /\Aimage/ }
  validates :name, presence: true, length: { maximum: 255 }
  validates :description_ru, :description_en, length: { maximum: 16_384 }

  scope :with_access_grants, -> {
    left_outer_joins(:access_grants)
      .group(:id)
      .select('oauth_applications.*, count(distinct(resource_owner_id)) as users_count')
  }

  before_save :restrict_scopes,
    if: -> {
      will_save_change_to_scopes? || will_save_change_to_allowed_scopes?
    }

  def scopes= value
    if value.is_a? Array
      super value.join ' '
    else
      super value
    end
  end

private

  def restrict_scopes
    self.scopes = allowed_scopes & scopes.to_a
  end
end
