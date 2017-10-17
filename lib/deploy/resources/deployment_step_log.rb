module Deploy
  class DeploymentStepLog < Resource
    def self.collection_path(params = {})
      "projects/#{params[:project].permalink}/deployments/#{params[:deployment].identifier}/steps/#{params[:step].identifier}/logs"
    end
  end
end
