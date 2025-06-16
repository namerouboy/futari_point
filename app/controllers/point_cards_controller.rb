class PointCardsController < ApplicationController
  # raise "FILE HAS BEEN LOADED"
  before_action :authenticate_user!, only: [:show, :index, :settings, :new, :create]
  before_action :set_card, only: [:show]

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
    @card = PointCard.find_by(id: params[:id], receiver_id: current_user.id)
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

end
