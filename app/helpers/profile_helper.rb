module ProfileHelper
  def last_reply_name(user)
    if user == current_user
      "Me"
    else
      user.profile.name
    end
  end

end
