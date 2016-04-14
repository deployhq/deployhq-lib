module Deploy
  class DeploymentStatusPoll
    attr_accessor :attributes

    def initialize(parsed_json)
      self.attributes = parsed_json
    end

    def status
      @status ||= attributes['status']
    end

    def taps
      return [] unless attributes['taps']
      @taps ||= attributes['taps'].map { |t| DeploymentTap.send(:create_object, t) }
    end

    class << self
      def poll_url(params)
        base = "projects/#{params[:project].permalink}/deployments/#{params[:deployment].identifier}/logs/poll"
        base += "?status=#{params[:status]}"
        base += "&since=#{params[:since]}" if params[:since]
        base
      end

      def poll(params = {})
        req = Request.new(poll_url(params)).make
        parsed = JSON.parse(req.output)

        new(parsed)
      end
    end
  end
end
