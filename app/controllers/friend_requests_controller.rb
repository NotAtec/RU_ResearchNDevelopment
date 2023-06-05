class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  # GET /friends
  def index
    @friends = current_user.friends
    @incoming = current_user.incoming_requests
    @outgoing = current_user.outgoing_requests
  end
end
