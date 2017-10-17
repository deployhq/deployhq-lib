module Deploy
  class DeploymentStep < Resource
    def default_params
      { deployment: self.deployment, project: self.deployment.project }
    end

    def logs(params = {})
      params = default_params.merge(step: self).merge(params)
      DeploymentStepLog.find(:all, params)
    end
  end
end
