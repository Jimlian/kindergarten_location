class KindergartensController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy, :join, :quit]
  before_action :validate_search_key, only: [:search]

  def show
   @kindergarten = Kindergarten.find(params[:id])
   @posts = @kindergarten.post.order("created_at DESC")

   if @kindergarten.is_hidden
   flash[:warning] = "This Kindergarten already archived"
   redirect_to root_path
   end
  end

  def index
    @locations = Location.published.sortA



    # 目前只能单个条件筛选 #
    # 判断是否筛选城市 #
    if params[:location].present?
      @location = params[:location]
      @location_id = Location.find_by(name: @location)

      if @location == '所有城市'
        @kindergartens = Kindergarten.published.recent.paginate(:page => params[:page], :per_page => 10)
      else
        @kindergartens = Kindergarten.where(:location => @location_id).published.recent.paginate(:page => params[:page], :per_page => 10)
      end

    # 判断是否筛选职位类型 #
    elsif params[:category].present?
      @category = params[:category]
      @category_id = Category.find_by(name: @category)

      if @category == '所有类型'
        @kindergartens = Kindergarten.published.recent.paginate(:page => params[:page], :per_page => 10)
      else
        @kindergartens = Kindergarten.where(:category => @category_id).published.recent.paginate(:page => params[:page], :per_page => 10)
      end

    # 判断是否筛选薪水 #
    elsif params[:wage].present?
      @wage = params[:wage]
      if @wage == '5k以下'
        @kindergartens = Kindergarten.wage1.published.recent.paginate(:page => params[:page], :per_page => 10)
      elsif @wage == '5~10k'
        @kindergartens = Kindergarten.wage2.published.recent.paginate(:page => params[:page], :per_page => 10)
      elsif @wage == '10~15k'
        @kindergartens = Kindergarten.wage3.published.recent.paginate(:page => params[:page], :per_page => 10)
      elsif @wage == '15~25k'
        @kindergartens = Kindergarten.wage4.published.recent.paginate(:page => params[:page], :per_page => 10)
      else
        @kindergartens = Kindergarten.wage5.published.recent.paginate(:page => params[:page], :per_page => 10)
      end

    # 预设显示所有公开职位 #
    else
      @kindergartens = Kindergarten.published.recent.paginate(:page => params[:page], :per_page => 1)
    end
  end



   def new
     @kindergarten = Kindergarten.new
   end

   def create
     @kindergarten = Kindergarten.new (kindergarten_params)
     @kindergarten.user = current_user


     if @kindergarten.save
       current_user.join!(@kindergarten)
       redirect_to kindergartens_path
     else
       render :new
     end
   end

   def edit
    @kindergarten = Kindergarten.find(params[:id])
   end

    def update
      @kindergarten = Kindergarten.find(params[:id])

      if @kindergarten.update(kindergarten_params)
        redirect_to kindergartens_path
      else
        render :edit
      end
    end

    def destroy
      @kindergarten = Kindergarten.find(params[:id])

      @kindergarten.destroy

      redirect_to kindergartens_path
    end

  def join
   @kindergarten = Kindergarten.find(params[:id])

    if !current_user.is_member_of?(@kindergarten)
      current_user.join!(@kindergarten)
      flash[:notice] = "加入本讨论版成功！"
    else
      flash[:warning] = "你已经是本讨论版成员了！"
    end

    redirect_to kindergarten_path(@kindergarten)
  end

  def quit
    @kindergarten = Kindergarten.find(params[:id])

    if current_user.is_member_of?(@kindergarten)
      current_user.quit!(@kindergarten)
      flash[:alert] = "已退出本讨论版！"
    else
      flash[:warning] = "你不是本讨论版成员，怎么退出 XD"
    end

    redirect_to kindergarten_path(@kindergarten)
  end
#search#
  def search
      if @query_string.present?
        search_result = Kindergarten.ransack(@search_criteria).result(:distinct => true)
        @kindergartens = search_result.paginate(:page => params[:page], :per_page => 5 )
      end
    end


    protected

    def validate_search_key
      @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
      @search_criteria = search_criteria(@query_string)
    end


    def search_criteria(query_string)
      { :title_cont => query_string }
    end
#search end#

   private

   def kindergarten_params
     params.require(:kindergarten).permit(:title, :description, :fee, :phone, :is_hidden, :location, :location)
   end


end
