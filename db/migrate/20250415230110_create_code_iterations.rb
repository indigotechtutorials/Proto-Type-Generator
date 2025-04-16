class CreateCodeIterations < ActiveRecord::Migration[8.0]
  def change
    create_table :code_iterations do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.text :code_content

      t.timestamps
    end
  end
end
