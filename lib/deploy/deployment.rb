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

    def current_status
      status = JSON.parse(Request.new(self.class.member_path(self.identifier, :project => self.project) + "/status").make.output)
      status['status']
    end

  end
end