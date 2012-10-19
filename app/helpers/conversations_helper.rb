module ConversationsHelper
  def to_hash_with_subject_as_keys(replies)
    temp = {}
    replies.each do |reply|
      temp[reply.subject] = [] if temp[reply.subject].nil?
      temp[reply.subject] << reply
    end
    return temp
  end
end
