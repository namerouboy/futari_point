Rails.application.routes.draw do
  root "point_cards#home"

  # deviseのルーティング
  devise_for :users

  # Railsのヘルスチェック用ルート
  # アプリが生きているかどうかを外部ツールが確認するために使う。
  get "up" => "rails/health#show", as: :rails_health_check

  # Renderのヘルスチェック用
  get "/up", to: proc { [200, {"Content-Type"=>"text/plain"}, ["OK"]] }

  # 所有しているポイントカードのidを指定して呼び出す
  resources :point_cards do
    member do
      patch :set_default # このポイントカードをログイン中ユーザーのデフォルトカードに設定←？
      get :settings # ポイントカード固有の設定画面
      patch :settings, action: :update_settings # 設定
      post :generate_pin # PINコード発行
      get :issued # PINコード表示
      post :receive_by_pin # PINコード入力
      post :add_stamp # スタンプ押下
    end
  end

  # 通知画面
  resources :notifications, only: [:index, :show]

  # 個人設定画面
  resource :settings

  get "menu", to: "menus#index"

  ###############################################################
  # 各画面の目的と対応アクション
  #
  # ・トップページ　　　　　：　home#index　　　：デフォルトポイントカード表示
  # ・ハンバーガーメニュー　：　menus#index　　　：ログアウト、通知、カード切り替え
  # ・pc一覧/切り替え　　　：　point_cards#index：一覧＋切り替えボタン
  # ・カード追加　　　　　　：　point_cards#new　：PIN入力＆生成
  # ・カード詳細　　　　　　：　point_cards#show　：通知詳細/カード一覧から遷移
  # ・カード設定　　　　　　：　point_cards#settings：倍デー、ごほうびメッセージ設定
  # ・通知一覧画面　　　　　：　notifications#index　：　ご褒美通知
  # ・通知詳細　　　　　　　：　notifications#show　　：　通知クリックで遷移
  # ・個人設定　　　　　　　：　settings#index　　　　：　登録情報変更画面へ遷移
  #
  ###############################################################

end
