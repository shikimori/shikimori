# модуль с логикой для модерируемых сущностей
module Moderatable
  def moderated?
    body =~ /\[moderator(=.*?)?\]/
  end
end
