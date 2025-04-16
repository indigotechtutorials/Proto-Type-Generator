require "fileutils"

class CodeIterationJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(project_id, user_request:)
    @project = Project.find(project_id)
    @user_request = user_request
    @code_iteration = @project.code_iterations.last
    if @code_iteration.present? && @code_iteration.code_content.present?
      additional_content = "use the following HTML content as a reference and update it with the new code: #{@code_iteration.code_content}"
    else
      additional_content = ""
    end
    ai_request_prompt = <<-AIRESPONSE
      generate HTML code for the following request: #{@user_request}
      use only inline CSS for styling and emit any <html> boiler plate code and only return plain html with inline CSS styles
      return html code like the following example: <div style=''> </div>
      #{ additional_content }
    AIRESPONSE

    client = Ollama.new(
      credentials: { address: 'http://localhost:11434' },
      options: { server_sent_events: true }
    )

    result = client.generate(
      { model:  'llama3.2',
        prompt: ai_request_prompt }
    )
    ai_response = result.map { |r| r["response" ] }.join

    @code_iteration = @project.code_iterations.create(code_content: ai_response, ai_response: ai_response)
    
    browser = Watir::Browser.new :chrome, headless: true

    browser.goto project_code_iteration_url(@project, @code_iteration)

    FileUtils.mkdir_p(Rails.root.join("tmp/screenshots"))
    screenshot_file_name = "#{@project.id}-#{@code_iteration.id}-screenshot.png"
    screenshot_path = Rails.root.join("tmp/screenshots/#{screenshot_file_name}")

    browser.screenshot.save screenshot_path

    File.open(screenshot_path) do |local_file|
      @code_iteration.preview.attach(io: local_file, filename: screenshot_file_name)
    end
  end
  def default_url_options
    { host: "localhost:3000" }
  end
end
