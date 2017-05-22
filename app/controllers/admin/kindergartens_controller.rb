class Admin::KindergartensController < ApplicationController
    before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy]
    before_action :require_is_admin
    layout "admin"

    def show
      @kindergarten = Kindergarten.find(params[:id])
    end

    def index
      @kindergartens = Kindergarten.all
    end

    def new
      @kindergarten = Kindergarten.new
    end

    def create
      @kindergarten = Kindergarten.new(kindergarten_params)
      @kindergarten.user = current_user

      if @kindergarten.save
        redirect_to admin_kindergartens_path
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
        redirect_to admin_kindergartens_path
      else
        render :edit
      end
    end

    def destroy
      @kindergarten = Kindergarten.find(params[:id])

      @kindergarten.destroy

      redirect_to admin_kindergartens_path
    end


    def publish
      @kindergarten = Kindergarten.find(params[:id])
      @kindergarten.is_hidden = false
      @kindergarten.save
      redirect_to :back
    end

    def hide
      @kindergarten = Kindergarten.find(params[:id])
      @kindergarten.is_hidden = true
      @kindergarten.save
      redirect_to :back
    end




    private

    def kindergarten_params
      params.require(:kindergarten).permit(:title, :description, :fee, :phone, :is_hidden, :location)
    end

end
