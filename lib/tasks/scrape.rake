namespace :scrape do 
  desc "Scraping JobsDB"
  task :get_jobs => :environment do

    require 'open-uri'
    require 'nokogiri'

    # approx 37300 jobs
    url = "http://hk.jobsdb.com/HK/EN/Search/FindJobs?KeyOpt=COMPLEX&JSRV=1&RLRSF=1&JobCat=1"

    scrape_this_url(url)
  end

  def scrape_this_url(url)

    if Job.all.count >= 1000
      return
    end

    document = open(url).read
    html_doc = Nokogiri::HTML(document)

    data_company = "div > div > div > p > a"
    company_details = html_doc.css(data_company)

    data_job_title = "div > div > div > h3 > a"
    job_details = html_doc.css(data_job_title)

    # get all 3 description items together to tie with the job
    data_job_description = "div > div > div > ul"
    # data_job_description = "div > div > div > ul > li"
    job_description = html_doc.css(data_job_description)

    data_job_id = "div.result-sherlock-cell"
    job_id = html_doc.css(data_job_id)

    puts "Number of jobs this page #{job_details.count}"
    #puts job_details.count
    #puts job_description.count
    if !company_details.any?
      puts "no company_details error "
      # put some error message here
      return
    end

    if company_details.count != job_details.count
      # some error msg
      puts "company_details.count != job_details.count"
      return
    end

    # first fill the db with companies
    counter = 0
    # there are 3 description lines for each job/ company
    counter_for_id = counter
    new_company_array = []
    new_job_array = []

    while counter < company_details.count do 
      puts ""
      puts "the company details are #{company_details[counter].text}"
      puts "checking if company exists in the array already - "
      puts new_company_array.include?(company_details[counter].text)
      unless new_company_array.include?(company_details[counter].text)
        new_company_array.push(company_details[counter].text)
        # create a record for this unique company
        Company.create(name: company_details[counter].text)
        puts "new company created #{company_details[counter].text}"
      end

      puts job_details[counter].text
      current_company = Company.find_by_name(company_details[counter].text)
      #puts "current company is " + current_company.name
      

      #if the id is null, it's advertising and we need to do the next one
      current_job_id = job_id[counter_for_id]['id']
      while !current_job_id
        counter_for_id += 1
        current_job_id = job_id[counter_for_id]['id']
        puts "counter is #{counter_for_id}, current_job_id is #{current_job_id}"
      end
        current_job_id.gsub!('Row', '')
        puts current_job_id
      
      current_job = current_company.jobs.new(position_name: job_details[counter].text, position_about: "", jobsdb_id: current_job_id)
      
      # JOB DESCRIPTION STUFF
      current_job_description_array = job_description[counter].css('li')

      hash_array = []
      current_job_description_array.each do |item|
        hash_array.push(item.text)
      end
      #puts hash_array

      current_job.position_about = {'desc' => hash_array}
 
      puts current_job.position_about
      current_job.save
      counter += 1
      counter_for_id += 1
    end

    # recursively call this function again until no more next links
    button_next_format = ".pagebox-next"
    next_url = html_doc.css(button_next_format)

    if next_url.any?
      next_url = next_url[0]['href']
      puts "about to scrape next page"
      scrape_this_url(next_url)
    else
      puts "No nextbutton #{next_url} - exiting"
    end

  end
end