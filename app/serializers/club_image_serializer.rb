class ClubImageSerializer < ActiveModel::Serializer
  attributes :id, :original_url, :main_url, :preview_url, :can_destroy, :user_id

  def original_url
    ImageUrlGenerator.instance.cdn_image_url object, :original
  end

  def main_url
    ImageUrlGenerator.instance.cdn_image_url object, :original
  end

  def preview_url
    ImageUrlGenerator.instance.cdn_image_url object, :preview
  end

  def can_destroy
    Ability.new(scope.current_user).can? :destroy, object if scope.current_user
  end
end
