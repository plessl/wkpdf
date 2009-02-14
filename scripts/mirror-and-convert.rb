#!/usr/bin/ruby

URL = 'http://www.example.com'

system("wget -E --mirror #{URL}")

BASE_DIR = URL

files = `find #{BASE_DIR} -name '*.html'`
files.each { |source_file|
source_file.chomp!
dest_file = source_file.sub(/(.*)\.html?/, '\1.pdf')
system("wkpdf --source #{source_file} --output #{dest_file} --format A5")
}
