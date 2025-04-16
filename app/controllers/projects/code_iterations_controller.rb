module Projects
  class CodeIterationsController < ApplicationController
    before_action :set_project
    layout false
    def create
      CodeIterationJob.perform_later(@project.id, user_request: params[:body])
      redirect_to @project, notice: "Updates have been made!"
    end

    def show
      @code_iteration = @project.code_iterations.find(params[:id])     
    end
  private
    def set_project
      @project = Project.find(params[:project_id])
    end
  end
end