class ListImport < ApplicationRecord
  belongs_to :user

  has_attached_file :list

  validates :user, presence: true
  validates :list, attachment_presence: true
end
