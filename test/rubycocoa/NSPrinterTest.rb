require 'osx/cocoa'
include OSX

#p = NSPrinter.printerTypes()

p = NSPrinter.printerWithType("Generic PostScript Printer")
puts "#{p}"

size = p.pageSizeForPaper("A4")
puts "size: width=#{size.width} height=#{size.height}"
