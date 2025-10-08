class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.integer :church_id, null: false
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.integer :status, default: 0, null: false
      t.integer :amount_cents, default: 2500, null: false
      t.string :currency, default: "usd", null: false
      t.string :interval, default: "year", null: false
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, default: false, null: false
      t.datetime :canceled_at

      t.timestamps
    end
    add_index :subscriptions, :church_id
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :status
    add_foreign_key :subscriptions, :churches
  end
end
