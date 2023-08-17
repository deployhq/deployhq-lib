# frozen_string_literal: true

module Deploy
  class Resource

    ## Store all attributes for the model we're working with.
    attr_accessor :id, :attributes, :errors

    ## Pass any methods via. the attributes hash to see if they exist
    ## before resuming normal method_missing behaviour
    def method_missing(method, *params)
      set = method.to_s.include?('=')
      key = method.to_s.sub('=', '')
      self.attributes = ({}) unless attributes.is_a?(Hash)
      if set
        attributes[key] = params.first
      else
        attributes[key]
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?('user_') || super
    end

    class << self

      ## Find a record or set of records. Passing :all will return all records and passing an integer
      ## will return the individual record for the ID passed.
      def find(type, params = {})
        case type
        when :all then find_all(params)
        else find_single(type, params)
        end
      end

      ## Find all objects and return an array of objects with the attributes set.
      def find_all(params)
        request = Request.new(collection_path(params))
        output = request.make.output
        output = JSON.parse(output)

        output = output['records'] if output.is_a?(Hash) && output['records'] && output['pagination']
        return [] unless output.is_a?(Array)

        output.map do |o|
          create_object(o, params)
        end
      end

      ## Find a single object and return an object for it.
      def find_single(id, params = {})
        request = Request.new(member_path(id, params))
        output = request.make.output
        output = JSON.parse(output)

        raise Deploy::Errors::NotFound, 'Record not found' unless output.is_a?(Hash)

        create_object(output, params)
      end

      ## Post to the specified object on the collection path
      def post(path)
        Request.new(path.to_s, :post).make
      end

      ## Return the collection path for this model. Very lazy pluralizion here
      ## at the moment, nothing in Deploy needs to be pluralized with anything
      ## other than just adding an 's'.
      def collection_path(_params = {})
        "#{class_name.downcase}s"
      end

      ## Return the member path for the passed ID & attributes
      def member_path(id, _params = {})
        [collection_path, id].join('/')
      end

      ## Return the deploy class name
      def class_name
        name.to_s.split('::').last.downcase
      end

      private

      ## Create a new object with the specified attributes and getting and ID.
      ## Returns the newly created object
      def create_object(attributes, objects = [])
        o = new
        o.attributes = attributes
        o.id         = attributes['id']
        objects.select { |_k, v| v.is_a?(Deploy::Resource) }.each do |key, object|
          o.attributes[key.to_s] = object
        end
        o
      end

    end

    ## Run a post on the member path. Returns the ouput from the post, false if a conflict or raises
    ## a Deploy::Error. Optionally, pass a second 'data' parameter to send data to the post action.
    def post(action, data = nil)
      path = "#{self.class.member_path(id, default_params)}/#{action}"
      request = Request.new(path, :post)
      request.data = data
      request.make
    end

    ## Delete this record from the remote service. Returns true or false depending on the success
    ## status of the destruction.
    def destroy
      Request.new(self.class.member_path(id, default_params), :delete).make.success?
    end

    def new_record?
      id.nil?
    end

    def save
      new_record? ? create : update
    end

    # rubocop:disable Metrics/AbcSize
    def create
      request = Request.new(self.class.collection_path(default_params), :post)
      request.data = { self.class.class_name.downcase.to_sym => attributes_to_post }
      if request.make && request.success?
        new_record = JSON.parse(request.output)
        self.attributes = new_record
        self.identifier = new_record['identifier']
        true
      else
        populate_errors(request.output)
        false
      end
    end
    # rubocop:enable Metrics/AbcSize

    ## Push the updated attributes to the remote. Returns true if the record was saved successfully
    ## other false if not. If not saved successfully, the errors hash will be updated with an array
    ## of all errors with the submission.
    def update
      request = Request.new(self.class.member_path(id, default_params), :put)
      request.data = { self.class.class_name.downcase.to_sym => attributes_to_post }
      if request.make && request.success?
        true
      else
        populate_errors(request.output)
        false
      end
    end

    private

    ## Populate the errors hash from the given raw JSON output
    def populate_errors(json)
      self.errors = ({})
      JSON.parse(json).each_with_object(errors) do |e, r|
        r[e.first] = e.last
      end
    end

    ## An array of params which should always be sent with this instances requests
    def default_params
      {}
    end

    ## Attributes which can be passed for update & creation
    def attributes_to_post
      attributes.each_with_object({}) do |(key, value), r|
        r[key] = value if value.is_a?(String) || value.is_a?(Integer)
      end
    end

  end
end
