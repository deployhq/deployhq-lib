module Deploy
  class Server < Base
    
    class << self
      def collection_path(params = {})
        "projects/#{params[:project].permalink}/servers"
      end
      
      def member_path(id, params = {})
        "projects/#{params[:project].permalink}/servers/#{identifier}"
      end
    end
    
    def default_params
      {:project => self.project}
    end
    
  end
end