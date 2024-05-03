class AppointmentsController < ApplicationController 
    skip_before_action :verify_authenticity_token,only: %i[create]

    def index
        if current_user.patient?
           @all_appointments = current_user.patient.appointments
        end
        if current_user.doctor?
            @all_appointments = current_user.doctor.appointments
        end
    end

    def new 
    end

    def create
        @appointment = Appointment.create( patient_id:current_user.patient.id , doctor_id:params[:doctor_id] , slot_time:params[:slot_time] , reason:params[:reason] )
        if @appointment.save
            flash[:notice] = "Appointment Booked Successfully , Confirmation sent to your Gmail !"    
            redirect_to appointments_path
        else
            flash[:alert] = "Booking Failed ! , You Must provide Reason for booking !"
            redirect_to request.referer
        end  
        #TRIGER MAIL !    
    end

    def show
        @status = params[:status]
        @appointment = Appointment.find(params[:id])
    end
    
    def destroy
        @appointment = Appointment.find(params[:id])
        @appointment.update(status:"canceled")
        flash[:notice] = "Appointment canceled Succesfully !"
        redirect_to appointments_path
        #TRIGER MAIL !
    end
    def edit
        @appointment = Appointment.find(params[:id])
    end
    def update
        @appointment = Appointment.find(params[:id])
        if check_status_param
            @appointment.update(status:params[:status])
            redirect_to appointments_path, notice: "Appointment updated successfully"
        end
        if @appointment.update(appointment_params)
          redirect_to appointments_path, notice: "Appointment updated successfully"
        else
            redirect_to appointments_path, alert: "Appointment updation Failed"
        end
        redirect_to appointments_path, notice: "Appointment updated successfully"

    end
    def download
        @appointment = Appointment.find(params[:id])
        @doctor = Doctor.find(@appointment.doctor_id)
        @doctor_name  =User.find(@doctor.user_id).name
        appointment_pdf = Prawn::Document.new
        appointment_pdf.text @appointment.slot_time
        appointment_pdf.text @appointment.reason
        appointment_pdf.text current_user.name
        appointment_pdf.text @doctor_name

       if params[:preview].present?
        send_data(appointment_pdf.render, filename: "Medicare_#{current_user.name}_#{@appointment.slot_time}.pdf",type: "application/pdf",disposition: 'inline')
       else
        send_data(appointment_pdf.render, filename: "Medicare_#{current_user.name}_#{@appointment.slot_time}.pdf",type: "application/pdf")
       end
    end

    private
      
    def appointment_params
        params.require(:appointment).permit(:reason, :note,:status)
    end

    def check_status_param
        params[:status].present?
    end
end