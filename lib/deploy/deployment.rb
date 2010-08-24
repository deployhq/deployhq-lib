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
    
  end
end