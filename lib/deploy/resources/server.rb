# frozen_string_literal: true

module Deploy
  class Server < Resource

    class << self

      def collection_path(params = {})
        "projects/#{params[:project].permalink}/servers"
      end

      def member_path(_id, params = {})
        "projects/#{params[:project].permalink}/servers/#{identifier}"
      end

    end

    def default_params
      { project: project }
    end

    def to_s
      [].tap do |a|
        a << name
        a << "(branch: #{preferred_branch})" if preferred_branch
        if last_revision
          a << "(currently: #{last_revision})"
        else
          a << '(currently undeployed)'
        end
      end.join(' ')
    end

  end
end
