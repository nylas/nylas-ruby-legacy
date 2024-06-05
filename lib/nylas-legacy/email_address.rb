# frozen_string_literal: true

module NylasLegacy
  # Structure to represent the Email Address Schema
  # @see https://docs.nylas.com/reference#contactsid
  class EmailAddress
    include Model::Attributable
    attribute :type, :string
    attribute :email, :string
    attribute :name, :string
  end
end
