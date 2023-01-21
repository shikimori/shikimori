# frozen_string_literal: true

class Article::Update < UserContent::UpdateBase
  klass Article
  is_publishable true
end
