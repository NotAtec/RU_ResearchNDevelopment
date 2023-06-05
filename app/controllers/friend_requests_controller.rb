class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  # GET /friends
  def index
    @friends = current_user.friends
    @incoming = current_user.incoming_requests
    @outgoing = current_user.outgoing_requests
  end

  # POST /friends
  def create
    user = User.find_by(username: params[:search][:name])
    if user
      @request = FriendRequest.new(requester_id: current_user.id, requestee_id: user.id)

      if @request.save
        redirect_to friends_path, notice: 'Completed Sucessfully.'
      else
        redirect_to friends_path, alert: 'Something went wrong, try again.'
      end
    else
      redirect_to friends_path, alert: 'User not found.'
    end
  end

  # PATCH /friends/:id
  def update
    @request = FriendRequest.find(params[:id])
    if @request.confirm(current_user.id)
      redirect_to friends_path, notice: 'Completed Sucessfully.'
    else
      redirect_to friends_path, notice: 'Something went wrong, try again.'
    end
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
