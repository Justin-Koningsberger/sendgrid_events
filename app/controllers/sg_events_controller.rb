class SgEventsController < ApplicationController
  #Is this safe enough?
  skip_before_action :verify_authenticity_token, :only => :create

  # GET /sg_events
  def index
    @sg_events = SgEvent.all

    respond_to do |format|
      format.html
    end
  end

  # POST /endpoint
  def create
    data = params[:_json].first
    #require 'pry'; binding.pry

    sg_event = SgEvent.create(
      :email => data['email'],
      :sg_event_id => data['sg_event_id'],
      :sg_message_id => data['sg_message_id'],
      :category => data['category'],
      :status => data['event'],
      :ip => data['ip'],
      :response => data['.response'],
      :tls => data['tls']
    )
  end

  private

  def sg_event_params
    params.require(:email).permit(:timestamp, :event, :smtp-id, :useragent, :ip, :sg_event_id, :sg_message_id, :reason, :status, :response, :tl, :url, :attempt, :category, :type)
  end
end
