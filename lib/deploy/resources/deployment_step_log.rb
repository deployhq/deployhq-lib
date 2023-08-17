# frozen_string_literal: true

module Deploy
  class DeploymentStepLog < Resource

    def self.collection_path(params = {})
      permalink = params[:project].permalink
      project_identifier = params[:project].identifier
      step_identifier = params[:step].identifier

      "projects/#{permalink}/deployments/#{project_identifier}/steps/#{step_identifier}/logs"
    end

  end
end
