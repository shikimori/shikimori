# frozen_string_literal: true

class Collection::Create < UserContent::CreateBase
  klass Collection
  is_auto_acceptable true
  is_publishable true
end
