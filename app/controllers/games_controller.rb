class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]
  before_action :verify_player, only: %i[show]

  # GET /games or /games.json
  def index
    @games = Game.where(player1_id: current_user.id, player2_accepted: true) + Game.where(player2_id: current_user.id, player2_accepted: true)
    @invites = Game.where(player2_id: current_user.id, player2_accepted: false)
  end

  # GET /games/1 or /games/1.json
  def show; end

  # GET /games/new
  def new
    @game = Game.new
    @friends = current_user.friends.map { |friend| [friend.username, friend.id] }
  end


  # POST /games or /games.json
  def create
    @game = Game.new(game_params)
    @game.current_question_id = Question.first.id # TODO: change this to a random question, given the topic, using GPT-3
    @game.player1_id = current_user.id
    @game.history << @game.current_question_id

    respond_to do |format|
      if @game.save
        #TD: Notification
        format.html { redirect_to game_url(@game), notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    if Game.update(params[:id], player2_accepted: true)
      #TD: Notification
      # TD: Make this the game-url
      redirect_to games_url, notice: 'Game was successfully accepted.'
    else
      redirect_to games_url, alert: 'Game could not be accepted, are you the invitee?'
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy
    #TD: Notification 

    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:player1_id, :player2_id, :topic)
  end

  def verify_player
    redirect_to games_url, alert: 'You are not a player of this game.' unless @game.player1_id == current_user.id || @game.player2_id == current_user.id
    redirect_to games_url, alert: 'This game has not been accepted yet.' unless @game.player2_accepted
  end
end
