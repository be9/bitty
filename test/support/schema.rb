ActiveRecord::Schema.define(:version => 0) do
  create_table "foos", :force => true do |t|
    t.integer  "bitval"
  end

  create_table "bars", :force => true do |t|
    t.integer  "bitval"
  end
end
