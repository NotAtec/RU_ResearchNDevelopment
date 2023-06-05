class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  # GET /friends
  def index
    @friends = current_user.friends
    @incoming = current_user.incoming_requests
    @outgoing = current_user.outgoing_requests
  end

  # DELETE /friends/:id
  def destroy
    @request = FriendRequest.find(params[:id])
    if @request.destroy
      redirect_to friends_path, notice: 'Completed Sucessfully.'
    else
      redirect_to friends_path, notice: 'Something went wrong, try again.'
    end
  end
end
