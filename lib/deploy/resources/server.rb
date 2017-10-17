module Deploy
  class Server < Resource

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

    def to_s
      Array.new.tap do |a|
        a << self.name
        a << "(branch: #{self.preferred_branch})" if self.preferred_branch
        if self.last_revision
          a << "(currently: #{self.last_revision})"
        else
          a << "(currently undeployed)"
        end
      end.join(' ')
    end

  end
end
