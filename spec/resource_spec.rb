# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Deploy::Resource do
  before do
    Deploy.configure do |config|
      config.account = 'https://test.deployhq.com'
      config.username = 'testuser'
      config.api_key = 'test-key'
    end
  end

  describe '#method_missing' do
    context 'for attribute access' do
      it 'allows reading attributes via method calls' do
        resource = described_class.new
        resource.attributes = { 'name' => 'Test Resource', 'status' => 'active' }

        expect(resource.name).to eq('Test Resource')
        expect(resource.status).to eq('active')
      end
    end

    context 'for attribute setting' do
      it 'allows setting attributes via method calls' do
        resource = described_class.new
        resource.name = 'New Name'
        resource.status = 'inactive'

        expect(resource.attributes['name']).to eq('New Name')
        expect(resource.attributes['status']).to eq('inactive')
      end
    end
  end

  describe '#new_record?' do
    context 'with no id' do
      it 'returns true' do
        resource = described_class.new
        expect(resource.new_record?).to be true
      end
    end

    context 'with an id' do
      it 'returns false' do
        resource = described_class.new
        resource.id = 123
        expect(resource.new_record?).to be false
      end
    end
  end

  describe '.class_name' do
    it 'returns the lowercase class name' do
      expect(described_class.class_name).to eq('resource')
    end
  end

  describe '.collection_path' do
    it 'returns the pluralized class name' do
      expect(described_class.collection_path).to eq('resources')
    end
  end

  describe '.member_path' do
    it 'returns the path for a specific resource' do
      expect(described_class.member_path(123)).to eq('resources/123')
    end
  end

  describe '.find' do
    context 'finding a single resource' do
      it 'returns a resource instance with attributes' do
        stub_request(:get, 'https://test.deployhq.com/resources/123')
          .with(
            basic_auth: %w[testuser test-key],
            headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 200,
            body: JSON.generate({ 'id' => 123, 'name' => 'Test Resource' }),
            headers: { 'Content-Type' => 'application/json' }
          )

        resource = described_class.find(123)

        expect(resource.id).to eq(123)
        expect(resource.name).to eq('Test Resource')
      end
    end

    context 'finding all resources' do
      it 'returns an array of resource instances' do
        stub_request(:get, 'https://test.deployhq.com/resources')
          .with(
            basic_auth: %w[testuser test-key],
            headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 200,
            body: JSON.generate([
                                  { 'id' => 1, 'name' => 'Resource 1' },
                                  { 'id' => 2, 'name' => 'Resource 2' }
                                ]),
            headers: { 'Content-Type' => 'application/json' }
          )

        resources = described_class.find(:all)

        expect(resources.length).to eq(2)
        expect(resources[0].id).to eq(1)
        expect(resources[0].name).to eq('Resource 1')
        expect(resources[1].id).to eq(2)
        expect(resources[1].name).to eq('Resource 2')
      end
    end

    context 'finding all resources with pagination' do
      it 'extracts records from paginated response' do
        stub_request(:get, 'https://test.deployhq.com/resources')
          .with(
            basic_auth: %w[testuser test-key],
            headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 200,
            body: JSON.generate({
                                  'records' => [
                                    { 'id' => 1, 'name' => 'Resource 1' },
                                    { 'id' => 2, 'name' => 'Resource 2' }
                                  ],
                                  'pagination' => { 'page' => 1, 'per_page' => 10 }
                                }),
            headers: { 'Content-Type' => 'application/json' }
          )

        resources = described_class.find(:all)

        expect(resources.length).to eq(2)
        expect(resources[0].id).to eq(1)
      end
    end
  end

  describe '#destroy' do
    it 'makes a DELETE request and returns true on success' do
      resource = described_class.new
      resource.id = 123

      stub_request(:delete, 'https://test.deployhq.com/resources/123')
        .with(
          basic_auth: %w[testuser test-key],
          headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: '', headers: {})

      expect(resource.destroy).to be true
    end
  end
end
