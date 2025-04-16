class CodeIteration < ApplicationRecord
  belongs_to :project
  has_one_attached :preview

  after_update_commit :broadcast_updates
private
  def broadcast_updates
    broadcast_update_to(project, target: "code-preview", 
      partial: "projects/code_iteration", 
      locals: { code_iteration: self } )
  end
end
