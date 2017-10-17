module Deploy
  class Deployment < Resource
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

    def steps
      if attributes['steps'].is_a?(Array)
        @steps ||= attributes['steps'].map do |step_params|
          DeploymentStep.new.tap do |step|
            step.attributes = step_params
            step.attributes['deployment'] = self
          end
        end
      else
        []
      end
    end
  end
end
