# frozen_string_literal: true

class Critique::Create < UserContent::CreateBase
  klass Critique
  is_auto_acceptable true
  is_publishable false
end
