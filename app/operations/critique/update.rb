# frozen_string_literal: true

class Critique::Update < UserContent::UpdateBase
  klass Critique
  is_publishable false
end
