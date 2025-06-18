# 基本設定ファイル(spec_helperを読み込む)
require 'spec_helper'
# Pumaサーバ(Railsを動かすためのアプリケーションサーバー)を使えるようにする
require 'rack/handler/puma'
require 'devise'
require 'warden'
require 'capybara/rspec'
require 'webdrivers/chromedriver'

# RAILS_ENV を test環境 にセット
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
#本番環境の場合エラーが発生したら停止する
abort("The Rails environment is running in production mode!") if Rails.env.production?

# RSpecとRailsの連携をセットアップ
require 'rspec/rails'

# spec/supportフォルダのファイルを読み込む
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# テスト用DBが最新かどうかチェック
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # テスト用ダミーデータ(fixtures)の保存先を設定
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # トランザクションの使用
  config.use_transactional_fixtures = true

  # RSpecのテストタイプ推論を有効にする
  config.infer_spec_type_from_file_location!

  # Railsエラーバックトレースを見やすくする
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Warden::Test::Helpers
  # controller spec でも Warden を初期化
  config.before(:suite) { Warden.test_mode! }
  config.after(:each)   { Warden.test_reset! }

  # shoulda-matchersの設定
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  # FactoryBotのシンタックスシュガーを有効にする
  config.include FactoryBot::Syntax::Methods

  # rspec-expectations config goes here. You can use an alternate assertion/expectation library if you prefer.
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.use_transactional_fixtures = true

  # コントローラテストでDeviseのヘルパーを使用できるようにする
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
end
