class Coub::Author < Dry::Struct
  attribute :permalink, Types::String
  attribute :name, Types::String
  attribute :avatar_template, Types::String

  VERSION_TEMPALTE = '%{version}' # rubocop:disable FormatStringToken
  # medium
  # medium_2x
  # profile_pic
  # profile_pic_new
  # profile_pic_new_2x
  # tiny
  # tiny_2x
  # small
  # small_2x
  # ios_large
  # ios_small

  def avatar_url
    avatar_template.gsub(VERSION_TEMPALTE, 'profile_pic_new')
  end

  def avatar_2x_url
    avatar_template.gsub(VERSION_TEMPALTE, 'profile_pic_new_2x')
  end
end
