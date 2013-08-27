module Deploy
  class DeploymentTap < Base
    
    class << self
      def collection_path(params = {})
        base = "projects/#{params[:project].permalink}/deployments/#{params[:deployment].identifier}.js"
        base += "?since=#{params[:since]}" if params[:since]
        base
      end
    end
    
    def default_params
      {:deployment => self.deployment, :project => self.deployment.project}
    end

  end
end