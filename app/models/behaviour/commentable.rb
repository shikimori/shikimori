module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, :class_name => "Comment",
                        :as => :commentable,
                        :dependent => :destroy,
                        :order => 'created_at DESC'
  end
end
