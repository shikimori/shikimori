json.kind params[:action]
json.value @comment.try(:"#{params[:action]}?") || false
json.affected_ids @ids
