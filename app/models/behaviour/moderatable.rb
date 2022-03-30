# refactor to models/concerns
# модуль с логикой для модерируемых сущностей
module Behaviour::Moderatable
  def moderated?
    body =~ /\[moderator(=.*?)?\]/
  end
end
