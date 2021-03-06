class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, except: [:new, :create]
  before_action :find_event, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      redirect_to root_path, notice: 'User created'
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      redirect_to root_path
    end
  end

  def show
    @sponsors = @event.sponsors
    @speakers = @event.speakers
  end

  def edit

  end

  def update
    if @user.update user_params
      redirect_to user_path(@user), notice: 'Profile Updated'
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @user.auth_token == session[:auth_token]
      @user.destroy
      session[:auth_token] = nil
      redirect_to root_path, notice: 'User deleted'
    else
      @user.destroy
      redirect_to user_path(@user)
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def find_user
    @user ||= User.find_by_auth_token session[:auth_token]
  end

  def find_event
    @event ||= Event.find_by_aasm_state 'current'
    flash[:alert] = 'This is not the upcoming event, please set an upcoming event.' if @event == nil
    @event = Event.where('start_date > ? AND aasm_state = ?', Date.today, 'published').first if @event == nil
    @event = Event.where('start_date > ?', Date.today).first if @event == nil
  end

end
