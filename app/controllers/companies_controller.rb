class CompaniesController < ApplicationController


  def index
    @companies = Company.all.order(name: :asc)
  end

  def show
    @company = Company.find(params[:id])
  end

end
