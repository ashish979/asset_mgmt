class TicketsController < ApplicationController
  before_action :find_ticket, only: [:show, :change_state]
  authorize_resource

  def index
    @tickets = current_company.tickets
    @tickets = @tickets.where(employee_id: current_employee.id) unless current_employee.has_role?(:admin)
    @tickets = @tickets.where(state: Ticket::STATE[params[:state].to_sym]) if params[:state].present?
    @tickets = @tickets.includes({asset: :asset_type}, :ticket_type, :employee).order("created_at desc").page(params[:page]).per_page(PER_PAGE)
  end

  def new
    @ticket = current_company.tickets.build
  end

  def create
    @ticket = current_company.tickets.build(params_ticket)
    @ticket.employee = current_employee
    if @ticket.save
      redirect_to tickets_path, :notice => "#{@ticket.title} has been submitted successfully"
    else
      render 'new'
    end
  end

  def show
    @comments = @ticket.comments.includes(:commenter).order("created_at asc")
    @comment = @ticket.comments.build 
  end

  def change_state
    @ticket.change_state!
    redirect_to :back, :notice => "#{@ticket.title} #{@ticket.open? ? 'reopened' : 'closed'} successfully"
  end

  def search
    state, query, category = params[:state], params[:search_query], params[:category]
    @tickets = Ticket.search(category, state, query, current_employee).includes({asset: :asset_type}, :ticket_type,:employee).page(params[:page]).per_page(PER_PAGE)
  end
  
  private
    def params_ticket
      params.require(:ticket).permit(:ticket_type_id, :description, :company_id, :employee_id, :state, :asset_id)
    end

    def find_ticket
      tickets = current_company.tickets.where(id: params[:id])
      tickets = tickets.where(employee_id: current_employee.id) unless current_employee.has_role?(:admin)
      @ticket = tickets.first
      redirect_to :back, :alert => "The ticket you are looking for does not exist." unless @ticket
    end

end