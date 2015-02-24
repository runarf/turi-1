class ParticipantsController < ApplicationController

  before_action :authenticate_user!
  #after_action :verify_authorized

  def index
    @trip = Trip.find(params[:trip_id])
    @participants = @trip.participants
  end

  def new
    @trip = Trip.find(params[:trip_id])
  end

  # Creates the participant with the given role if the current user is allowed to execute this action.
  # Returns a redirect or renders an error
  def create
    @trip = Trip.find(params[:trip_id])
    @participant_user = User.find_by!(email: params[:user_email])

    @role = ParticipantRole.viewer

    if(params[:editor_flag])
      @role = ParticipantRole.editor
    end

    @participant = @trip.participants.create(user_id: @participant_user.id, participant_role_id: @role.id)

    if @participant.save
      flash[:notice] = I18n.t 'trip_participant_added', :email => @participant_user.email
      redirect_to trip_participants_path(@trip)
    else
      flash[:alert] = I18n.t 'trip_participant_not_added'
      render :new
    end
  end

  # Removes the participant if the current user is allowed to execute this action.
  # Returns a redirect or renders an error
  def destroy
    @trip = Trip.find(params[:trip_id])
    @participant = Participant.find(params[:id])

    authorize @participant

    user_email = @participant.user.email

    @participant.destroy
    flash[:notice] = I18n.t 'trip_participant_removed', :email => user_email
    redirect_to trip_participants_path(@trip)
  end

end
