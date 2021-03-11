require 'base64'
require 'digest'
require 'openssl'

class SgEventsController < ApplicationController
  #Is this safe enough? Done for curl posting events, probably better to remove this in production
  skip_before_action :verify_authenticity_token, :only => :create

  SIGNATURE = "HTTP_X_TWILIO_EMAIL_EVENT_WEBHOOK_SIGNATURE".freeze
  TIMESTAMP = "HTTP_X_TWILIO_EMAIL_EVENT_WEBHOOK_TIMESTAMP".freeze

  # GET /sg_events
  def index
    @sg_events = SgEvent.all

    respond_to do |format|
      format.html
    end
  end

  # POST /endpoint
  def create
    #HMM, hard to test this, ask on slack

    # return unless request.headers[SIGNATURE]
    # signature = request.headers[SIGNATURE]
    # public_key = convert_public_key_to_ecdsa(ENV['SENDGRID-API-KEY'])
    # timestamp = request.headers[TIMESTAMP]

    # if verify_signature(public_key, params, signature, timestamp)
      data = params[:_json].first

      sg_event = SgEvent.create(
        :email => data['email'],
        :smtp_id => data['smtp-id'],
        :sg_event_id => data['sg_event_id'],
        :sg_message_id => data['sg_message_id'],
        :category => data['category'],
        :status => data['event'],
        :ip => data['ip'],
        :response => data['.response'],
        :tls => data['tls']
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
