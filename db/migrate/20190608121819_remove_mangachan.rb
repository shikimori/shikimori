class RemoveMangachan < ActiveRecord::Migration[5.2]
  def up
    ExternalLink.where("kind = 'mangachan'").update_all source: Types::ExternalLink::Source[:hidden]
  end
end
