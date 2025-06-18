RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # カスタムマッチャーの説明文にチェーンを含める（RSpec4ではtrueがデフォルト）
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # 実在しないメソッドをスタブしようとしたらエラーにする
    mocks.verify_partial_doubles = true
  end

  # `shared_context` のメタデータを継承する（RSpec4のデフォルト）
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # 以下は必要なものだけ有効化
  # 例：特定のテストだけ実行したいときに使う :focus
  # config.filter_run_when_matching :focus

  # 例：最後に失敗したテストだけ再実行するための状態保存ファイル
  # config.example_status_persistence_file_path = "spec/examples.txt"

  # 例：ランダム実行による順序依存テストの発見
  # config.order = :random
  # Kernel.srand config.seed
end