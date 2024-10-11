# frozen_string_literal: true

module Deploy
  class Project < Resource

    ## Return all deployments for this project
    def deployments
      Deployment.find(:all, project: self)
    end

    ## Return a deployment
    def deployment(identifier)
      Deployment.find(identifier, project: self)
    end

    def latest_revision(branch = '')
      branch ||= 'master'
      req = Request.new(self.class.member_path(permalink) + "/repository/latest_revision?branch=#{branch}").make
      parsed = JSON.parse(req.output)
      parsed['ref']
    end

    # Create a deployment in this project (and queue it to run)
    def deploy(server, start_revision, end_revision, config_files_only: false)
      run_deployment(server, start_revision, end_revision) do |d|
        d.mode = 'queue'
        d.config_files_deployment = '1' if config_files_only
      end
    end

    def config_files_deployment(server)
      deploy(server, nil, nil, config_files_only: true)
    end

    # Create a deployment preview
    def preview(server, start_revision, end_revision)
      run_deployment(server, start_revision, end_revision) do |d|
        d.mode = 'preview'
      end
    end

    ## Return all servers for this project
    def servers
      Server.find(:all, project: self)
    end

    def server_groups
      ServerGroup.find(:all, project: self)
    end

    private

    def run_deployment(server, start_revision, end_revision, &block)
      d = Deployment.new
      d.project = self
      d.parent_identifier = (server.is_a?(Server) ? server.identifier : server)
      d.start_revision = start_revision
      d.end_revision = end_revision
      d.copy_config_files = '1'
      d.email_notify = '1'
      block.call(d) if block_given?
      d.save
      d
    end

  end
end
