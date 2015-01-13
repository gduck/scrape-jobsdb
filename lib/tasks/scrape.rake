namespace :scrape do 
  desc "Scraping JobsDB"
  task :get_jobs => :environment do

    require 'open-uri'
    require 'nokogiri'

    url = "http://hk.jobsdb.com/HK/EN/Search/FindJobs?KeyOpt=COMPLEX&JSRV=1&RLRSF=1&JobCat=1&SearchFields=Positions,Companies&Key=part%20time&Locations=153&EM_Locations=1&JobTypes=2&JSSRC=JSRAS&keepExtended=1"
    document = open(url).read
    html_doc = Nokogiri::HTML(document)

    data_company = "div > div > div > p > a"
    company_details = html_doc.css(data_company)


    data_job_title = "div > div > div > h3 > a"
    job_details = html_doc.css(data_job_title)

    data_job_description = "div > div > ul.job-summary > li"
    job_description = html_doc.css(data_job_description)

    button_next_format = ".pagebox.pagebox-next"


    puts company_details.count
    puts job_details.count
    puts job_description.count
    if !company_details.any?
      # put some error message here
      return
    end

    if company_details.count != job_details.count
      # some error msg
      return
    end

    # first fill the db with companies
    counter = 0
    # there are 3 description lines for each job/ company
    counter_for_description = counter
    new_company_array = []
    new_job_array = []

    while counter < company_details.count do 
      
      if !new_company_array.include? company_details[counter].text
        new_company_array.push(company_details[counter].text)
        # create a record for this unique company
        Company.create(name: company_details[counter].text)
      end

      puts job_details[counter].text
      current_company = Company.find_by_name(company_details[counter].text)
      puts "current company is " + current_company.name

      current_job = current_company.jobs.new(position_name: job_details[counter].text, position_about: "")

      #, position_about: job_description[counter].text)
      
      three_line_counter = 0
      while three_line_counter < 3 do
        #puts job_description[counter_for_description].text
        current_job.position_about += job_description[counter_for_description].text + ".  "
        counter_for_description += 1
        three_line_counter += 1
      end
      current_job.save
      puts current_job.position_about
      counter += 1
    end

  
  end
end