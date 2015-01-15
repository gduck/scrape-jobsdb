class CompaniesController < ApplicationController


  def index
    @companies = Company.search(params[:search]).order(name: :asc)
  end

  def show
    @company = Company.find(params[:id])
  end

end
