class OauthApplication < Doorkeeper::Application
  belongs_to :user

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

  validates :user, presence: true
  validates :image, attachment_content_type: { content_type: /\Aimage/ }
end
