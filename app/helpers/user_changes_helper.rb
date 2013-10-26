module UserChangesHelper
  def user_change_status_color(status)
    case status
      when UserChangeStatus::Pending, 'pending' then 'orange'
      when UserChangeStatus::Accepted, 'accepted' then 'green'
      when UserChangeStatus::Taken then 'blue'
      when UserChangeStatus::Rejected, 'rejected'  then 'red'
      when UserChangeStatus::Deleted then 'maroon'
      when UserChangeStatus::Locked then 'purple'
    end
  end
end
