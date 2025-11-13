# frozen_string_literal: true

require 'test_helper'

class ResourceTest < Minitest::Test

  def setup
    Deploy.configure do |config|
      config.account = 'https://test.deployhq.com'
      config.username = 'testuser'
      config.api_key = 'test-key'
    end
  end

  def test_method_missing_for_attribute_access
    resource = Deploy::Resource.new
    resource.attributes = { 'name' => 'Test Resource', 'status' => 'active' }

    assert_equal 'Test Resource', resource.name
    assert_equal 'active', resource.status
  end

  def test_method_missing_for_attribute_setting
    resource = Deploy::Resource.new
    resource.name = 'New Name'
    resource.status = 'inactive'

    assert_equal 'New Name', resource.attributes['name']
    assert_equal 'inactive', resource.attributes['status']
  end

  def test_new_record_with_no_id
    resource = Deploy::Resource.new
    assert resource.new_record?
  end

  def test_existing_record_with_id
    resource = Deploy::Resource.new
    resource.id = 123
    refute resource.new_record?
  end

  def test_class_name
    assert_equal 'resource', Deploy::Resource.class_name
  end

  def test_collection_path
    assert_equal 'resources', Deploy::Resource.collection_path
  end

  def test_member_path
    assert_equal 'resources/123', Deploy::Resource.member_path(123)
  end

  def test_find_single_success
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

    resource = Deploy::Resource.find(123)

    assert_equal 123, resource.id
    assert_equal 'Test Resource', resource.name
  end

  def test_find_all_success
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

    resources = Deploy::Resource.find(:all)

    assert_equal 2, resources.length
    assert_equal 1, resources[0].id
    assert_equal 'Resource 1', resources[0].name
    assert_equal 2, resources[1].id
    assert_equal 'Resource 2', resources[1].name
  end

  def test_find_all_with_pagination
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

    resources = Deploy::Resource.find(:all)

    assert_equal 2, resources.length
    assert_equal 1, resources[0].id
  end

  def test_destroy_success
    resource = Deploy::Resource.new
    resource.id = 123

    stub_request(:delete, 'https://test.deployhq.com/resources/123')
      .with(
        basic_auth: %w[testuser test-key],
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
      )
      .to_return(status: 200, body: '', headers: {})

    assert resource.destroy
  end

end
