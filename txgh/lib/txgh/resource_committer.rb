module Txgh
  class ResourceCommitter
    DEFAULT_COMMIT_MESSAGE = "Updating %{language} translations in %{file_name}"

    attr_reader :project, :repo, :logger

    def initialize(project, repo, logger = nil)
      @project = project
      @repo = repo
      @logger = logger || Logger.new(STDOUT)
    end

    def commit_resource(tx_resource, branch, language)
      return if prevent_commit_on?(branch)
      return if language == tx_resource.source_lang

      file_name, translations = download(tx_resource, branch, language)
      message = commit_message_for(language, file_name)

      return unless translations

      repo.api.update_contents(
        branch, [{ path: file_name, contents: translations }], message
      )

      Txgh.events.publish(
        'github.resource.committed', {
          project: project, repo: repo, resource: tx_resource,
          language: language, branch: branch
        }
      )
    end

    private

    def download(tx_resource, branch, language)
      downloader = ResourceDownloader.new(
        project, repo, branch, {
          languages: [language], resources: [tx_resource]
        }
      )

      downloader.first
    end

    def commit_message_for(language, file_name)
      commit_message_template % {
        language: language, file_name: file_name
      }
    end

    def commit_message_template
      repo.commit_message || DEFAULT_COMMIT_MESSAGE
    end

    def prevent_commit_on?(branch)
      project.protected_branches.include?(branch)
    end
  end
end
