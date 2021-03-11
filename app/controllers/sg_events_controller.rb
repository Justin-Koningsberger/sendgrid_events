require 'base64'
require 'digest'
require 'openssl'

class SgEventsController < ApplicationController
  #Is this safe enough? Done for curl posting events, probably better to remove this in production
  skip_before_action :verify_authenticity_token, :only => :create

  SIGNATURE = "HTTP_X_TWILIO_EMAIL_EVENT_WEBHOOK_SIGNATURE".freeze
  TIMESTAMP = "HTTP_X_TWILIO_EMAIL_EVENT_WEBHOOK_TIMESTAMP".freeze
  VERIFICATION_KEY = "SENDGRID-WEBHOOK-VERIFICATION-KEY".freeze

  # GET /sg_events
  def index
    if params[:search]
      @sg_events = SgEvent.where('lower(sg_events.email) LIKE ?', "%#{params[:search]}%")
    elsif params[:filter]
      @sg_events = SgEvent.where('lower(sg_events.status) LIKE ?', "%#{params[:filter]}%")
    else
      @sg_events = SgEvent.all
    end

    respond_to do |format|
      format.html
    end
  end

  # POST /endpoint
  def create
    #HMM, hard to test this, ask on slack

    # return unless request.headers[SIGNATURE]
    # signature = request.headers[SIGNATURE]
    # public_key = convert_public_key_to_ecdsa(ENV[VERIFICATION_KEY])
    # timestamp = request.headers[TIMESTAMP]

    # # params may need to be params[:_json]
    # if verify_signature(public_key, params, signature, timestamp)
      data = params[:_json].first
      event = data['event']
      reason = data['reason']
      email = data['email']
      
      unless event.nil? || reason.nil?
        remove_hard_bounced_mail_addresses(event, reason, email)
      end

      sg_event = SgEvent.create(
        :email => email,
        :smtp_id => data['smtp-id'],
        :sg_event_id => data['sg_event_id'],
        :sg_message_id => data['sg_message_id'],
        :category => data['category'],
        :status => event,
        :ip => data['ip'],
        :response => data['response'],
        :tls => data['tls'],
        :reason => reason
      )
    # end
  end

  # GET /sg_events/:id
  def show
    @sg_event = SgEvent.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  private
  def remove_hard_bounced_mail_addresses(event, reason, email)
    if event == 'bounce' &&  reason.start_with(550.to_s)
      # I don't know exactly where/how you store email addresses,
      # but I would call something like db.delete(email), or don't
      # delete the address and mark it as non-existant
    end
  end

  class Error < ::RuntimeError
  end

  class NotSupportedError < Error
  end

  def convert_public_key_to_ecdsa(public_key)
    verify_engine
    OpenSSL::PKey::EC.new(Base64.decode64(public_key))
  end

  def verify_signature(public_key, payload, signature, timestamp)
    verify_engine
    timestamped_payload = "#{timestamp}#{payload}"
    payload_digest = Digest::SHA256.digest(timestamped_payload)
    decoded_signature = Base64.decode64(signature)
    public_key.dsa_verify_asn1(payload_digest, decoded_signature)
  rescue StandardError
    false
  end

  def verify_engine
    # JRuby does not fully support ECDSA: https://github.com/jruby/jruby-openssl/issues/193
    raise NotSupportedError, "Event Webhook verification is not supported by JRuby" if RUBY_PLATFORM == "java"
  end
end
