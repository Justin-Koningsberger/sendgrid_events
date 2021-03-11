class AddReasonToSgEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :sg_events, :reason, :string
  end
end
