class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence:true, uniqueness: true
  validates :username, presence:true, uniqueness: true
  

  has_many :requests, class_name: 'FriendRequest', foreign_key: 'requester_id', dependent: :destroy
  has_many :received_requests, class_name: 'FriendRequest', foreign_key: 'requestee_id', dependent: :destroy

  def friends
    requests.where(confirmed: true).map(&:requestee) + received_requests.where(confirmed: true).map(&:requester)
  end

  def incoming_requests
    received_requests.where(confirmed: false)
  end

  def outgoing_requests
    requests.where(confirmed: false)
  end
end
