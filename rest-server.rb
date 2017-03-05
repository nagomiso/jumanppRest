require 'json'
require 'open3'
require 'csv'
require 'bundler/setup'
require 'sinatra'

# to use in Docker NAT 
set :bind, '0.0.0.0'
opts = { command: 'jumanpp' }

jumanpp_stdin, jumanpp_stdout = Open3.popen2(opts[:command], "r+") 

MORPH_INFO_KEYS = [ :surface_form,
                    :pronunciation,
                    :entry_word,
                    :part_category,
                    :part_category_id,
                    :part_class,
                    :part_class_id,
                    :conjugational_type,
                    :conjugational_type_id,
                    :conjugational_form,
                    :conjugational_form_id,
                    :semantic_infomation ].freeze

# required that jumanpp is installed before execution
# input: {`sentence': '(sentence)'
# output: JSON data by separated word and detail information of word.
post '/jumanpp' do
  params = JSON.parse(request.body.read)

  sentence = params['sentence'].to_s
  jumanpp_stdin.puts(sentence)
  response = []

  jumanpp_stdout.each do |line|
    line.chomp!
    break if line == 'EOS'
    splited_line = CSV.parse_line(line.force_encoding('utf-8'), col_sep: ' ')
    if line.start_with?('@')
      splited_line.shift
      morph_info = response.pop
      splited_line.each_with_index do |col, idx|
        morph_info[MORPH_INFO_KEYS[idx]] << col
      end
    else
      morph_info = Hash[MORPH_INFO_KEYS.zip(splited_line.map {|v| Array(v) })]
    end
    response << morph_info
  end

  response.to_json
end
