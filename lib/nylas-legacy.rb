# frozen_string_literal: true

require "json"
require "rest-client"

# BUGFIX
#   See https://github.com/sparklemotion/http-cookie/issues/27
#   and https://github.com/sparklemotion/http-cookie/issues/6
#
# CookieJar uses unsafe class caching for dynamically loading cookie jars
# If 2 rest-client instances are instantiated at the same time, (in threads)
# non-deterministic behaviour can occur whereby the Hash cookie jar isn't
# properly loaded and cached.
# Forcing an instantiation of the jar onload will force the CookieJar to load
# before the system has a chance to spawn any threads.
# Note this should technically be fixed in rest-client itself however that
# library appears to be stagnant so we're forced to fix it here
# This object should get GC'd as it's not referenced by anything
HTTP::CookieJar.new

require "ostruct"
require "forwardable"

require_relative "nylas-legacy/version"
require_relative "nylas-legacy/errors"

require_relative "nylas-legacy/logging"
require_relative "nylas-legacy/registry"
require_relative "nylas-legacy/types"
require_relative "nylas-legacy/constraints"

require_relative "nylas-legacy/http_client"
require_relative "nylas-legacy/api"
require_relative "nylas-legacy/collection"
require_relative "nylas-legacy/model"

# Attribute types supported by the API
require_relative "nylas-legacy/email_address"
require_relative "nylas-legacy/event"
require_relative "nylas-legacy/file"
require_relative "nylas-legacy/folder"
require_relative "nylas-legacy/im_address"
require_relative "nylas-legacy/label"
require_relative "nylas-legacy/message_headers"
require_relative "nylas-legacy/message_tracking"
require_relative "nylas-legacy/participant"
require_relative "nylas-legacy/physical_address"
require_relative "nylas-legacy/phone_number"
require_relative "nylas-legacy/recurrence"
require_relative "nylas-legacy/rsvp"
require_relative "nylas-legacy/timespan"
require_relative "nylas-legacy/web_page"
require_relative "nylas-legacy/nylas_date"
require_relative "nylas-legacy/when"
require_relative "nylas-legacy/free_busy"
require_relative "nylas-legacy/time_slot"
require_relative "nylas-legacy/time_slot_capacity"
require_relative "nylas-legacy/open_hours"
require_relative "nylas-legacy/event_conferencing"
require_relative "nylas-legacy/event_conferencing_details"
require_relative "nylas-legacy/event_conferencing_autocreate"
require_relative "nylas-legacy/event_notification"
require_relative "nylas-legacy/component"

# Custom collection types
require_relative "nylas-legacy/event_collection"
require_relative "nylas-legacy/search_collection"
require_relative "nylas-legacy/deltas_collection"
require_relative "nylas-legacy/free_busy_collection"
require_relative "nylas-legacy/calendar_collection"
require_relative "nylas-legacy/component_collection"
require_relative "nylas-legacy/scheduler_collection"
require_relative "nylas-legacy/job_status_collection"
require_relative "nylas-legacy/outbox"

# Models supported by the API
require_relative "nylas-legacy/account"
require_relative "nylas-legacy/calendar"
require_relative "nylas-legacy/contact"
require_relative "nylas-legacy/contact_group"
require_relative "nylas-legacy/current_account"
require_relative "nylas-legacy/deltas"
require_relative "nylas-legacy/delta"
require_relative "nylas-legacy/draft"
require_relative "nylas-legacy/message"
require_relative "nylas-legacy/room_resource"
require_relative "nylas-legacy/new_message"
require_relative "nylas-legacy/raw_message"
require_relative "nylas-legacy/thread"
require_relative "nylas-legacy/webhook"
require_relative "nylas-legacy/scheduler"
require_relative "nylas-legacy/job_status"
require_relative "nylas-legacy/token_info"
require_relative "nylas-legacy/application_details"
require_relative "nylas-legacy/outbox_message"
require_relative "nylas-legacy/outbox_job_status"
require_relative "nylas-legacy/send_grid_verified_status"

# Neural specific types
require_relative "nylas-legacy/neural"
require_relative "nylas-legacy/neural_sentiment_analysis"
require_relative "nylas-legacy/neural_ocr"
require_relative "nylas-legacy/neural_categorizer"
require_relative "nylas-legacy/neural_clean_conversation"
require_relative "nylas-legacy/neural_contact_link"
require_relative "nylas-legacy/neural_contact_name"
require_relative "nylas-legacy/neural_signature_contact"
require_relative "nylas-legacy/neural_signature_extraction"
require_relative "nylas-legacy/neural_message_options"
require_relative "nylas-legacy/categorize"
require_relative "nylas-legacy/scheduler_config"
require_relative "nylas-legacy/scheduler_time_slot"
require_relative "nylas-legacy/scheduler_booking_request"
require_relative "nylas-legacy/scheduler_booking_confirmation"

require_relative "nylas-legacy/native_authentication"

require_relative "nylas-legacy/filter_attributes"

require_relative "nylas-legacy/services/tunnel"
# an SDK for interacting with the Nylas API
# @see https://docs.nylas.com/reference
module NylasLegacy
  Types.registry[:account] = Types::ModelType.new(model: Account)
  Types.registry[:calendar] = Types::ModelType.new(model: Calendar)
  Types.registry[:contact] = Types::ModelType.new(model: Contact)
  Types.registry[:delta] = DeltaType.new
  Types.registry[:draft] = Types::ModelType.new(model: Draft)
  Types.registry[:email_address] = Types::ModelType.new(model: EmailAddress)
  Types.registry[:event] = Types::ModelType.new(model: Event)
  Types.registry[:file] = Types::ModelType.new(model: File)
  Types.registry[:folder] = Types::ModelType.new(model: Folder)
  Types.registry[:im_address] = Types::ModelType.new(model: IMAddress)
  Types.registry[:label] = Types::ModelType.new(model: Label)
  Types.registry[:room_resource] = Types::ModelType.new(model: RoomResource)
  Types.registry[:message] = Types::ModelType.new(model: Message)
  Types.registry[:message_headers] = MessageHeadersType.new
  Types.registry[:message_tracking] = Types::ModelType.new(model: MessageTracking)
  Types.registry[:participant] = Types::ModelType.new(model: Participant)
  Types.registry[:physical_address] = Types::ModelType.new(model: PhysicalAddress)
  Types.registry[:phone_number] = Types::ModelType.new(model: PhoneNumber)
  Types.registry[:recurrence] = Types::ModelType.new(model: Recurrence)
  Types.registry[:thread] = Types::ModelType.new(model: Thread)
  Types.registry[:timespan] = Types::ModelType.new(model: Timespan)
  Types.registry[:web_page] = Types::ModelType.new(model: WebPage)
  Types.registry[:nylas_date] = NylasDateType.new
  Types.registry[:contact_group] = Types::ModelType.new(model: ContactGroup)
  Types.registry[:when] = Types::ModelType.new(model: When)
  Types.registry[:time_slot] = Types::ModelType.new(model: TimeSlot)
  Types.registry[:time_slot_capacity] = Types::ModelType.new(model: TimeSlotCapacity)
  Types.registry[:event_conferencing] = Types::ModelType.new(model: EventConferencing)
  Types.registry[:event_conferencing_details] = Types::ModelType.new(model: EventConferencingDetails)
  Types.registry[:event_conferencing_autocreate] = Types::ModelType.new(model: EventConferencingAutocreate)
  Types.registry[:event_notification] = Types::ModelType.new(model: EventNotification)
  Types.registry[:neural] = Types::ModelType.new(model: Neural)
  Types.registry[:categorize] = Types::ModelType.new(model: Categorize)
  Types.registry[:neural_signature_contact] = Types::ModelType.new(model: NeuralSignatureContact)
  Types.registry[:neural_contact_link] = Types::ModelType.new(model: NeuralContactLink)
  Types.registry[:neural_contact_name] = Types::ModelType.new(model: NeuralContactName)
  Types.registry[:scheduler_config] = Types::ModelType.new(model: SchedulerConfig)
  Types.registry[:scheduler_time_slot] = Types::ModelType.new(model: SchedulerTimeSlot)
  Types.registry[:job_status] = Types::ModelType.new(model: JobStatus)
  Types.registry[:outbox_message] = Types::ModelType.new(model: OutboxMessage)
end
