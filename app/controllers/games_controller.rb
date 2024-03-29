class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game, only: %i[show edit update destroy process_choice result]
  before_action :verify_player, only: %i[show process_choice result]

  # GET /games or /games.json
  def index
    @games = Game.where(player1_id: current_user.id, player2_accepted: true) + Game.where(player2_id: current_user.id, player2_accepted: true)
    @invites = Game.where(player2_id: current_user.id, player2_accepted: false)
  end

  # GET /games/1 or /games/1.json
  def show
    @question = Question.find(@game.current_question_id)
  end

  # GET /games/new
  def new
    @game = Game.new
    fr = current_user.friends.map { |f| f.requester_id == current_user.id ? f.requestee : f.requester}
    @friends = fr.map { |f| [f.username, f.id] }
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
        format.html { redirect_to games_url, notice: 'Game was successfully created. Wait for your opponent to accept it before playing.' }
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
    @winner = @game.winner
    @game.destroy
    #TD: Notification 

    respond_to do |format|
      format.html { redirect_to games_url, notice: "The game has ended. #{@winner}" }
      format.json { head :no_content }
    end
  end

  def process_choice
    if @game.answered_by(current_user.id)
      redirect_to game_url(@game), alert: 'You have already answered this question.'
      return
    end

    @game.answered(current_user.id, params[:choice])
    @game.next

    redirect_to result_path(@game), notice: 'Answer was successfully processed.'
  end

  def result
    @question = Question.find(@game.current_question_id)
    @correct = @question.options.find(&:correct)

    @choice = @game.chosen_by(current_user.id, @question)
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
