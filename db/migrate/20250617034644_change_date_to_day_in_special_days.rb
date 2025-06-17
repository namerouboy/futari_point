class ChangeDateToDayInSpecialDays < ActiveRecord::Migration[8.0]
  def up
    # date → integer に変える。「date 型の列 date を整数(日)に変換」
    change_column :special_days, :date,
                  'integer USING EXTRACT(DAY FROM date)'
  end

  def down
    # もとの date 型に戻す時は、とりあえず当月の日付で埋め戻す例
    change_column :special_days, :date,
                  'date USING TO_DATE(date::text, \'DD\')'
  end
end
