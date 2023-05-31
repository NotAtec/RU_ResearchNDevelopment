class FriendRequest < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :requestee, class_name: 'User'
  validates :confirmed, inclusion: { in: [true, false] }

  def confirm(user_id)
    update(confirmed: true) if requestee_id == user_id
  end
end
