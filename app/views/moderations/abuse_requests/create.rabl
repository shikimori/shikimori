node :kind do
  params[:action]
end

node :value do
  if @comment.respond_to? params[:action]
    @comment[params[:action]]
  else
    false
  end
end

node :affected_ids do
  @ids
end
