class SgEventsController < ApplicationController
  # GET /sg_events
  def index
    @sg_events = SgEvent.all

    respond_to do |format|
      format.html
    end
  end
end
