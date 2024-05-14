class RenameForbiddenNicknames < ActiveRecord::Migration[7.0]
  def up
    User.where(nickname: NameValidator::PREDEFINED_PATHS).find_each do |user|
      user.update! nickname: user.nickname + '_'
      puts user.nickname
    end
  end
end
