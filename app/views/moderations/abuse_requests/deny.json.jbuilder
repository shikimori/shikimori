if @resource.errors.any?
  json.error @resource.errors.full_messages.join('<br>')
end
