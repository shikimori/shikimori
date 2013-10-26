# выполняется каждый заход на страницу
#Warden::Manager.after_set_user do |user, auth, opts|
  #Rails.logger.info '---------'
  #user.prolongate_ban
#end

Warden::Manager.after_authentication do |user, auth, opts|
  #Rails.logger.info '========='
  user.prolongate_ban
end
