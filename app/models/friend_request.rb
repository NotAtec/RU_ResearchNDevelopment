class FriendRequest < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :requestee, class_name: 'User'
  validates :confirmed, inclusion: { in: [true, false] }

  def confirm(user_id)
    update(confirmed: true) if requestee_id == user_id
  end

  def correct_name(user_id)
    requester_id == user_id ? requestee.username : requester.username
  end

  def cor_map(user_id)
    map = []
    u = requester_id == user_id ? requestee.username : requester.username
    map << u
    map << requester_id == user_id ? requestee.id : requester.id
    map
    
  end
end
