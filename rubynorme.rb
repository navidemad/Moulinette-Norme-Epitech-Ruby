#!/usr/bin/ruby

##
# RubyNorme Class
# Author: Navid 'emad_n' EMAD
##

class RubyNorme

	# Version
	VERSION = 1.0

	def initialize(files={})
		@files = files
		@currentLineNo = nil
		@countEOLconsecutively = nil
		@score = 0
	end

	def displayScore()
		if @score != 0
			puts "\n#{Colors::RED}### Score malus: '-#{@score}'#{Colors::NOCOLOR}"
		else
			puts "\n#{Colors::GREEN}### Score: 'no error norme found'#{Colors::NOCOLOR}"
		end
	end

	def displayFilename(file)
		puts "#{Colors::YELLOW}### Checking file: '#{file}'#{Colors::NOCOLOR}"
	end

	def isValidExtension?(filename)
		File.extname(filename) == ".c" || File.extname(filename) != ".h"
	end

	def checkHeader!(lineContent)
		errorNorme "incorrect header" if 
			(
			(@currentLineNo == 1 && lineContent != "/*\n") ||
			(@currentLineNo == 9 && lineContent != "*/\n") ||
			(@currentLineNo != 1 && @currentLineNo != 9 && lineContent[0, 2] != "**")
			)
	end

	def check80Columns(lineContent)
		errorNorme "more than 80 characters" if 
			(lineContent.gsub(/\t/, '    ').length > 80)
	end

	def checkTrailingSpaces(lineContent)
		errorNorme "space at the EOL" if 
			(lineContent =~ /[ \t]$/)
	end

	def checkWrongPositionSpaces(lineContent)
		errorNorme "space after a keyword" if
			(lineContent =~ /[ \t](if|else|return|while|for)(\()/)
	end

	def checkWrongPositionComa(lineContent)
		quote = false
		for n in 0..lineContent.length - 1
			quote = !quote if lineContent[n].chr == "'" || lineContent[n].chr == '"'
			errorNorme "invalide coma position" if
				(((lineContent[n].chr == ";" || lineContent[n].chr == ",") && !quote) && lineContent[n + 1].chr != " " && lineContent[n + 1].chr != "\n")
		end
	end

	def checkNbMaxArguments(lineContent)
		errorNorme "more than 4 arguments in parameters functions" if
			(lineContent[-2..-1] == ")\n" && lineContent =~ /\((.*),(.*),(.*),(.*),(.*)\)$/)
	end

	def checkNbEOLconsecutively(lineContent)
		if lineContent == "\n"
			errorNorme "double EOL consecutively" if @countEOLconsecutively >= 1
			@countEOLconsecutively += 1
		else
			@countEOLconsecutively = 0
		end
	end

	def checkLine!(lineContent)
		check80Columns lineContent
		checkTrailingSpaces lineContent
		checkWrongPositionSpaces lineContent
		checkWrongPositionComa lineContent
		checkNbMaxArguments lineContent
		checkNbEOLconsecutively lineContent
	end

	def parseFile(filename)
		displayFilename filename
		@currentLineNo = 1
		@countEOLconsecutively = 0
		begin
			File.readlines(filename).each do |lineContent|
				if @currentLineNo <= 9
					checkHeader! lineContent
				else
					checkLine! lineContent
				end
			    @currentLineNo += 1
			end
		rescue Exception => e
			puts e.message  
			puts e.backtrace.inspect  	
		end
	end

	def checkNorme()
		@files.each do |filename|
			next if !isValidExtension? filename
			parseFile filename
		end
		displayScore
	end

	def errorNorme(type)
		print "#{Colors::COLOR1}line #{@currentLineNo}#{Colors::NOCOLOR}"
		print " => '#{Colors::PURPLE}#{type}'#{Colors::NOCOLOR}\n"
		@score += 1
	end

end 

class Colors
   COLOR1 = "\e[1;36;40m"
   PURPLE = "\e[1;35;40m"
   NOCOLOR = "\e[0m"
   RED = "\e[1;31;40m"
   GREEN = "\e[1;32;40m"
   DARKGREEN = "\e[0;32;40m"
   YELLOW = "\e[1;33;40m"
   DARKCYAN = "\e[0;36;40m"
end

RubyNorme.new( ARGV ).checkNorme
