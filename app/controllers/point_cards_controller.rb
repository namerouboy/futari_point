class PointCardsController < ApplicationController
  # raise "FILE HAS BEEN LOADED"
  before_action :authenticate_user!, only: [:home, :show, :index, :settings, :new, :create]
  before_action :set_card, only: [:show, :settings, :update_settings] 

  # ホーム画面
  def home
    @card =
      # カードを指定して遷移した場合
      if params[:id].present?
        current_user.received_point_cards.find_by!(
          id: params[:id]
        )
      else
        # カードを指定せずrootを開いた場合、所持カードのうち最もidが若いカードを表示
        current_user.received_point_cards.order(:id).first
      end

      if @card
        render :show
      else
      # 所持カードが 1 枚も無い場合
        redirect_to new_point_card_path,
                  alert: "まだカードがありません。まずは PIN を受け取るか新規作成してください。"
      end
  end

  # スタンプ押下
  def add_stamp
    @card = current_user.received_point_cards.find(params[:id])
    sd = @card.special_days.find_by(date: Date.current.day)

    @card.point_records.create!(added_by_user: current_user, points: sd ? sd.multiplier : 1)

    if @card.current_points % 20 == 0 && @card.current_points != 0
      new_round = @card.current_points / 20
      @card.update!(current_round: new_round)
    end

    respond_to do |format|
      format.turbo_stream   # add_stamp.turbo_stream.erb を探す
      format.html { redirect_to point_card_path(@card) }
    end
  end

  # カード一覧
  def index
    @point_cards = current_user.received_point_cards
  end

  # カード表示
  def show
    @card = current_user.received_point_cards.find(params[:id])
  end

  # カード設定画面
  def settings
    build_missing_children
  end

  def settings_params          # ← メソッド名は settings_params でも可。必ず update_settings で呼ぶ
  params.require(:point_card).permit(
    # point_cards テーブルの直接の属性があればここに :title などを書く
    special_days_attributes:  [:id, :date, :multiplier, :_destroy],
    rewards_attributes:       [:id, :required_points, :name, :message, :_destroy]
  )
end

def update_settings
  if @card.update(settings_params)   # ← ここで必ずこのメソッドを呼ぶ
    redirect_to settings_point_card_path(@card), notice: "保存しました"
  else
    build_missing_children             # 失敗したら空行を補充
    render :settings, status: :unprocessable_entity
  end
end

  # カード作成
  def new
    @point_card = PointCard.new
  end

  def create
    if params[:commit] == "PIN で受け取る"
      receive_by_pin
    elsif params[:commit] == "新しいカードを作る"
      generate_new_card
    else
      redirect_to point_cards_path, alert: "不明な操作です"
    end
  end

  def issued
  @card = PointCard.find_by(id: params[:id], giver_id: current_user.id)
  end

  private

   # 既存カードを PIN で受け取る
  def receive_by_pin
    card = PointCard.find_by(pin_code: params[:pin_code])
    if card.nil?
      redirect_to new_point_card_path, alert: "PIN が見つかりません"

    elsif card.giver_id == current_user.id
      redirect_to new_point_card_path, alert: "自分のカードは受け取ることができません"

    elsif current_user.received_point_cards.exists?(card.id)
      redirect_to point_cards_path, alert: "すでに受け取っています"

    else
      current_user.received_point_cards << card
      redirect_to point_cards_path, notice: "カードを受け取りました！"
    end
  end

  # 新規カードを生成して PIN を発行
  def point_card_params
    params.require(:point_card).permit(:title, :message)
  end

  def generate_new_card
    card = current_user.given_point_cards.create!(point_card_params)
    redirect_to issued_point_card_path(card), notice: "カードを作成しました。PIN: #{card.pin_code}"
  end

  # 自分が受け取ったカードだけ閲覧可にする
  def set_card
    @card = current_user.received_point_cards.find_by!(id: params[:id])
    # ここで 404 が起きれば Rails が自動で 404 ページを返す
  end

  def settings_params
    params.require(:point_card).permit(
      special_days_attributes:  %i[id date multiplier _destroy],
      rewards_attributes:       %i[id required_points name message _destroy]
    )
  end

  def build_missing_children
    (3 - @card.special_days.size).times { @card.special_days.build }
    (3 - @card.rewards.size).times      { @card.rewards.build     }
  end

end
