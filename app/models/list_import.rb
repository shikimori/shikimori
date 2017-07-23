class ListImport < ApplicationRecord
  belongs_to :user

  has_attached_file :list

  validates :user, presence: true
  validates_attachment :list,
    presence: true,
    content_type: { content_type: 'application/xml' }
end
