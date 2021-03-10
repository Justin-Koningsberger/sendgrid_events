class CreateSgEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :sg_events do |t|
      t.string :email, null: false
      t.string :smtp_id
      # store "timestamp" from sg? or use our own timestamps
      t.string :sg_event_id
      t.string :sg_message_id
      t.string :category
      t.string :status
      t.string :ip
      t.string :response
      t.string :tls

      t.timestamps
    end
  end
end
