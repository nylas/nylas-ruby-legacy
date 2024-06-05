# frozen_string_literal: true

require "spec_helper"

describe NylasLegacy::Collection do
  def example_instance_json
    '{ "id": "1234" }'
  end

  def example_instance_hash
    JSON.parse(example_instance_json, symbolize_names: true)
  end

  let(:api) { FakeAPI.new }

  describe "#each" do
    it "Returns an enumerable for a single page of results, filtered by `offset` and `limit` and `where`" do
      allow(api).to receive(:execute)
        .with(
          auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return([example_instance_hash])

      collection = described_class.new(model: FullModel, api: api)

      results = collection.each.to_a

      expect(results.count).to be 1
    end

    it "allows you to use a block directly" do
      allow(api).to receive(:execute)
        .with(
          auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return([example_instance_hash])

      collection = described_class.new(model: FullModel, api: api)

      results = collection.each.to_a
      how_many = 0
      results.each do
        how_many += 1
      end

      expect(how_many).to be 1
    end
  end

  describe "#find_each" do
    it "iterates over every page filtered based on `limit` and `where`" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute)
        .with(
          auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0 },
          headers: {}
        ).and_return(Array.new(100) { example_instance_hash })

      allow(api).to receive(:execute)
        .with(
          auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 100 },
          headers: {}
        ).and_return(Array.new(50) { example_instance_hash })

      expect(collection.find_each.to_a.size).to be 150
    end
  end

  describe "#find" do
    it "retrieves a single object, without filtering based upon `where` clauses earlier in the chain" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).with(
        auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: {},
        headers: {}
      ).and_return(example_instance_hash)

      instance = collection.find(1234)

      expect(instance.id).to eql "1234"
      expect(instance.api).to eq(api)
    end

    it "retrieves with `view` argument in query if clauses earlier in the chain" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).and_return(example_instance_hash)

      instance = collection.expanded.find(1234)

      expect(instance.id).to eql "1234"
      expect(instance.api).to eq(api)
      expect(api).to have_received(:execute).with(
        auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: { view: "expanded" },
        headers: {}
      )
    end

    it "retrieves without `view` argument in query if not clauses earlier in the chain" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute).and_return(example_instance_hash)

      instance = collection.find(1234)

      expect(instance.id).to eql "1234"
      expect(instance.api).to eq(api)
      expect(api).to have_received(:execute).with(
        auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: {},
        headers: {}
      )
    end

    it "allows `api` to be sent to the related attributes" do
      collection = described_class.new(model: FullModel, api: api)
      expected_response = example_instance_hash.merge(
        files: [
          {
            id: "file-id"
          }
        ]
      )
      allow(api).to receive(:execute).with(
        auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
        method: :get,
        path: "/collection/1234",
        query: {},
        headers: {}
      ).and_return(expected_response)

      instance = collection.find(1234)

      expect(instance.files.first.api).to eq(api)
    end
  end

  describe "#where" do
    it "raises a NotImplementedError stating the model is not searchable when the model is not searchable" do
      collection = described_class.new(model: NonFilterableModel, api: api)
      expect { collection.where(id: "1234") }.to raise_error(NylasLegacy::ModelNotFilterableError)
    end
  end

  describe "#create" do
    it "sends the data to the appropriate endpoint using a post"
    it "Raises a not implemented error if the model is not creatable" do
      collection = described_class.new(model: NotCreatableModel, api: api)
      expect { collection.create(string: "1234") }.to raise_error(NylasLegacy::ModelNotCreatableError)
    end
  end

  describe "#count" do
    it "returns collection count" do
      FullModel.countable = true
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute)
        .with(
          auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { limit: 100, offset: 0, view: "count" },
          headers: {}
        ).and_return(count: 1)

      expect(collection.count).to be 1
    end

    it "returns collection count filtered by `where`" do
      collection = described_class.new(model: FullModel, api: api)
      allow(api).to receive(:execute)
        .with(
          auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
          method: :get,
          path: "/collection",
          query: { id: "1234", limit: 100, offset: 0, view: "count" },
          headers: {}
        ).and_return(count: 1)

      expect(collection.where(id: "1234").count).to be 1
    end

    describe "models that are not countable" do
      it "still returns collection count" do
        FullModel.countable = false
        collection = described_class.new(model: FullModel, api: api)
        allow(api).to receive(:execute)
          .with(
            auth_method: NylasLegacy::HttpClient::AuthMethod::BEARER,
            method: :get,
            path: "/collection",
            query: { limit: 100, offset: 0 },
            headers: {}
          ).and_return([{ id: "abc123" }])

        expect(collection.count).to be 1
      end
    end
  end

  describe "HTTP errors" do
    http_codes_errors = {
      400 => NylasLegacy::InvalidRequest,
      401 => NylasLegacy::UnauthorizedRequest,
      402 => NylasLegacy::MessageRejected,
      403 => NylasLegacy::AccessDenied,
      404 => NylasLegacy::ResourceNotFound,
      405 => NylasLegacy::MethodNotAllowed,
      410 => NylasLegacy::ResourceRemoved,
      418 => NylasLegacy::TeapotError,
      422 => NylasLegacy::MailProviderError,
      429 => NylasLegacy::SendingQuotaExceeded,
      500 => NylasLegacy::InternalError,
      501 => NylasLegacy::EndpointNotYetImplemented,
      502 => NylasLegacy::BadGateway,
      503 => NylasLegacy::ServiceUnavailable,
      504 => NylasLegacy::RequestTimedOut
    }

    http_codes_errors.each do |code, error|
      it "raises error if API returns #{error} with #{code}" do
        api = NylasLegacy::API.new
        model = instance_double("Model")
        allow(model).to receive(:searchable?).and_return(true)
        allow(model).to receive(:resources_path)
        allow(model).to receive(:auth_method)
        collection = described_class.new(model: model, api: api)
        stub_request(:get, "https://api.nylas.com/search?limit=100&offset=0&q=%7B%7D")
          .to_return(status: code, body: {}.to_json)

        expect do
          collection.search({}).last
        end.to raise_error(error)
      end
    end
  end
end
