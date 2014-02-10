object @comment

attributes :id, :body
attributes offtopic: :offtopic?

node(:user) {|v| v.user.nickname }
node(:kind) { 'comment' }
