class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_item, only: :order  # 「find_item」を動かすアクションを限定
  before_action :move_to_index, only: [:edit, :update, :destory, :order_show, :order]


  def index
    # 上から、出品された日時が新しい順に表示されること("created_at DESC")
    @items = Item.includes(:user).order("created_at DESC")
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    # エラーハンドリングができていること（入力に問題がある状態で「出品する」ボタンが押された場合、情報は保存されず、出品ページに戻りエラーメッセージが表示されること）
    if @item.valid?
      @item.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def show
    @item = Item.find(params[:id])
    @messages = @item.messages.includes(:user).order("created_at DESC")
    @message = Message.new
  end

  def edit
    @item = Item.find(params[:id])
   end

  def update
    @item = Item.find(params[:id])
    # @item = Item.includes(:item_purchase).order(created_at: :desc).with_attached_image    @item.update(item_params)
    if current_user.id == @item.user.id
      @item.update(item_params)
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def destroy
    @item = Item.find(params[:id])
    if current_user.id == @item.user.id
      @item.destroy
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def order_show
    @item = Item.find(params[:id])
    @user = current_user
  end
  
  def order # 購入する時のアクションを定義
    redirect_to new_card_path and return unless current_user.card.present?
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"] # 環境変数を読み込む
    customer_token = current_user.card.customer_token # ログインしているユーザーの顧客トークンを定義
    Payjp::Charge.create(
      amount: @item.price, # 商品の値段
      customer: customer_token, # 顧客のトークン
      currency: 'jpy' # 通貨の種類（日本円）
    )
    Order.create(item_id: params[:id],user_id: current_user.id) # 商品のid情報を「item_id」として保存する
    binding.pry
    redirect_to root_path

  end

  private

  def find_item
    @item = Item.find(params[:id]) # 購入する商品を特定
  end

  def item_params
    params.require(:item).permit(
      :name,
      :info,
      :category_id,
      :sales_status_id,
      :shipping_fee_status_id,
      :prefecture_id,
      :scheduled_delivery_id,
      :price,
      images:[]
    ).merge(user_id: current_user.id)
  end
  
  def move_to_index
    return redirect_to root_path if current_user.id == find_item.user_id || find_item.order != nil
  end
  
  

end
