# frozen_string_literal: true

module NylasLegacy
  # Structure to represent the Phone Number Schema
  # @see https://docs.nylas.com/reference#contactsid
  class PhoneNumber
    include Model::Attributable
    attribute :type, :string
    attribute :number, :string
  end
end
