class ApplicationController < ActionController::Base
  # サポート外のブラウザからの利用を拒否する設定らしい
  allow_browser versions: :modern

  # 認証画面で名前を入力させるための追加設定
  # すべてのリクエストの前に configure_permitted_parameters メソッドを呼び出す
  # ただし、if: :devise_controller? → Deviseが提供するコントローラ（ログインやユーザー登録など）の時だけ
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # configure_permitted_parameters メソッド
  # デフォルトのDeviseだとメールとパスワードしか許可されてないので、名前を許可するよう変更
  def configure_permitted_parameters
    # ユーザ登録時に:nameパラメータを許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])

    # アカウント編集時に:nameパラメータを許可する
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
