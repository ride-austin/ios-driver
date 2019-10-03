require 'nokogiri'
require './testrail'

def get_result_cases
	result_cases = []
	status = {"Success" => 6, "Failure" => 7}

	doc = File.open("report") { |f| Nokogiri::XML(f) }
	doc.xpath("//testcase").each do |testcase|
		test_name = testcase["name"]
		split_result = test_name.split("_")
		if split_result.count >= 2
			case_id = split_result[-1]
			if case_id.end_with?("()")
				case_id = case_id[0..-3]
			end
			test_status = status[testcase["status"]]
			result_case = {:case_id => case_id, :status_id => test_status}
			result_cases.push(result_case)
		end	
	end

	return result_cases
end

def send_test_report
	client = TestRail::APIClient.new('https://testrail.devfactory.com/')
	client.user = 'jroberto'
	client.password = 'Kd3e7B6Hyc'

	ride_austin_project_id = "322"

	begin
		add_run_body = {:suite_id => "6449", :name => "Driver iOS Automation"} #Regression - Driver App (iOS) TestSuite
		response = client.send_post("add_run/#{ride_austin_project_id}", add_run_body)
		run_id = response["id"]

		#1) Configure Request Body with all test Results
		results_cases_body = {:results => get_result_cases}

		#2) Send Test cases Results
		client.send_post("add_results_for_cases/#{run_id}", results_cases_body)

		#client.send_post("close_run/#{run_id}", {})

	rescue Exception => msg
		puts "An error has ocurred! #{msg}"
	end
end

send_test_report