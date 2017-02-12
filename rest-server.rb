require 'sinatra'
require 'json'

# to use in Docker NAT 
set :bind, '0.0.0.0'

opts = {'command'=>'jumanpp'}

rnnlm = IO.popen(opts['command'], "r+") 


# required that jumanpp is installed before execution
# input: {`sentense': '(sentense)'
# output: JSON data by separated word and detail information of word.
post '/jumanpp' do

	params = JSON.parse(request.body.read)

	rnnlm.puts(params['sentense'])

	response_to_word_number = { 1 => "surface_form", 
		     2 => "pronunciation",
		     3 => "entry_word",
		     4 => "part_category",
		     5 => "part_category_id",
		     6 => "part_class",
		     7 => "part_class_id",
		     8 => "conjugational_form",
		     9 => "conjugational_form_id",
		     10 => "conjugational_form_id",
		     11 => "semantic_infomation"
	}


	response = {}
	response_to_word = {}

	word_number = 1

 	while true
		cnt = 1
		f = rnnlm.gets
		break if f.to_s == "EOS\n"
		result_to_word = f.to_s.force_encoding('utf-8').split(" ")
	  	result_to_word.each do |result_contents|
			response_to_word[response_to_word_number[cnt]] = result_contents
		  	cnt += 1	
		  	puts response_to_word
	  	end
	  	cnt = 1
		response[word_number] = response_to_word
		response_to_word = {}
		word_number += 1
        end
        puts response
	return response.to_json
end
