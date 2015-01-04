class BookingsController < ApplicationController
  require 'asset-manager'
    
  API_BASE_URL = "http://orient-vega.codio.io:9292/" # base url of the API
  

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.tomorrow
    if @date < Date.tomorrow
        @date = Date.tomorrow
    end
      
    params[:status]||= 'all'

    if params[:view]=="calendar"
       status = 'all'
    else 
       status = params[:status]
    end
    @status = params[:status]

      
    if params[:resource_id].nil? || params[:view]=='own_bookings'
        
        @own_bookings = Booking.get("/bookings", user: current_user.id, status: @status)
        render 'index_own'  
    else 
      
       @resource = Resource.find(params[:resource_id]) 
       bookings = Booking.for_resource(@resource.id).where(status: status).where(date: @date)

       if params[:view]!='calendar' && params[:status]!='all'
          @all_slots=bookings
       else
          availability = Availability.for_resource(@resource.id).where(date: @date)
          @all_slots = bookings + availability
          @all_slots.sort! { |a,b| a[:start] <=> b[:start]}
       end
    

       if params[:view]=="calendar"
          render 'index_calendar'
       else 
          render 'index_list'
       end
    end
  end

  def new 
     render 'bookings/new' , layout: false
  end

  def create
    @resource = Resource.find(params[:resource_id])
    @booking = Booking.for_resource(@resource.id).create
    @booking.from = params[:from]
    @booking.to = params[:to]
    @booking.user = params[:user]
    
    begin
      if @booking.save
        flash[:notice] = "Booking Saved successfully"
        UserMailer.booking_created(@booking, @resource).deliver
        redirect_to resource_bookings_path(view: params[:view],status: params[:status])
      else 
          flash[:error] = "Booking Failed to save"
          redirect_to resource_bookings_path(view: params[:view],status: params[:status])
      end
    rescue Exception => e
     flash[:error] = "Booking Failed to save"
     render :new
    end
  end

  def edit

  end

  def update
    @resource = Resource.find(params[:resource_id])
    @booking = Booking.for_resource(@resource.id).find(params[:id])
    begin
      @booking.save
      UserMailer.booking_approved(@booking, @resource).deliver
      flash[:notice] = "Booking Updated successfully"
    rescue Exception => e
      flash[:error] = "Booking Failed to Update"
    end
      redirect_to resource_bookings_path(view: params[:view],status: params[:status])
  end

  def destroy
      @resource = Resource.find(params[:resource_id])
      @booking=Booking.for_resource(@resource.id).find(params[:id])
    begin
        status=@booking.status
        @booking.destroy
        if status == 'pending'
            flash[:notice] = "Booking Rejected successfully"
            UserMailer.booking_rejected(@booking, @resource).deliver
        else
            flash[:notice] = "Booking Cancelled successfully"
            UserMailer.booking_cancelled(@booking, @resource).deliver
        end
    rescue Exception => e
        if status == 'pending'
            flash[:error] = "Booking Failed to Reject"
        else 
            flash[:error] = "Booking Failed to Cancel"
        end            
    end
      redirect_to resource_bookings_path(view: params[:view],status: params[:status])
  end

end