module Deploy
  class Deployment < Base

    class << self
      def collection_path(params = {})
        "projects/#{params[:project].permalink}/deployments"
      end

      def member_path(id, params = {})
        "projects/#{params[:project].permalink}/deployments/#{id}"
      end
    end

    def default_params
      {:project => self.project}
    end

    def project
      if self.attributes['project'].is_a?(Hash)
        self.attributes['project'] = Project.send(:create_object, self.attributes['project'])
      end
      self.attributes['project']
    end

    def taps(params={})
      params = {:deployment => self, :project => self.project}.merge(params)
      DeploymentTap.find(:all, params)
    end

    def status_poll(params = {})
      params = {:deployment => self, :project => self.project}.merge(params)
      DeploymentStatusPoll.poll(params)
    end

  end
end
