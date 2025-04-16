class AddAiResponseToCodeIterations < ActiveRecord::Migration[8.0]
  def change
    add_column :code_iterations, :ai_response, :text
  end
end
