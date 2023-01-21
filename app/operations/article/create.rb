# frozen_string_literal: true

class Article::Create < UserContent::CreateBase
  klass Article
  is_auto_acceptable true
  is_publishable true
end
