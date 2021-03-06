class JobsController < ApplicationController
  def all
    if session[:user_id]
      jobs = User.find(session[:user_id]).jobs
      json_jobs = []
      jobs.each do |job|
        json_job = job.as_json
        json_job['company_name'] = Company.find(job.company_id).name if job.company_id
        json_job['job_status_category'] = JobStatus.find(job.job_status_id).category if job.job_status_id
        json_jobs.push json_job
      end
      render json: json_jobs
    else
      redirect_to '/'
    end
  end

  def create
    if session[:user_id]
      job = Job.new
      job.user_id = session[:user_id]
      job.job_status = JobStatus.find(params[:status]) if params[:status]
      if params[:company_id] != 'NaN'
        job.company = Company.find(params[:company_id])
      end
      job.title = params[:title]
      job.pros = params[:pros]
      job.cons = params[:cons]
      if params[:applied]
        job.date_applied = params[:applied]
      end
      job.contact_name = params[:contact_name]
      job.contact_phone = params[:contact_phone]
      job.contact_email = params[:contact_email]
      job.located = params[:located]
      job.salary = params[:salary]
      job.notes = params[:notes]
      if job.save
        render json: job
      else
        render json: {error: "Job has failed to save."}
      end
    else
      redirect_to '/'
    end
  end

  def show
    if Job.exists? params[:id]
      job = Job.find params[:id]
      if job.user_id == session[:user_id]
        render json: job
      else
        render json: {error: "ID is assigned to a different user."}
      end
    else
      render json: {error: "ID does not exist"}
    end
  end

  def update
    if Job.exists? params[:id]
      job = Job.find params[:id]
      if job.user_id == session[:user_id]
        job.job_status = JobStatus.find(params[:status]) if params[:status]
        if params[:company_id] != 'NaN'
          job.company = Company.find(params[:company_id])
        end
        job.title = params[:title]
        job.pros = params[:pros]
        job.cons = params[:cons]
        job.date_applied = params[:applied]
        job.contact_name = params[:contact_name]
        job.contact_phone = params[:contact_phone]
        job.contact_email = params[:contact_email]
        job.located = params[:located]
        job.salary = params[:salary]
        job.notes = params[:notes]
        if job.save
          render json: job
        else
          render json: {error: "Job has failed to update."}
        end
      else
        render json: {error: "ID is assigned to a different user."}
      end
    else
      render json: {error: "ID does not exist"}
    end
  end

  def destroy
    if Job.exists? params[:id]
      job = Job.find params[:id]
      tasks = job.tasks
      tasks.each do |task|
        task.destroy
      end
      if job.user_id == session[:user_id]
        job.destroy
      end
    end
  end

end
