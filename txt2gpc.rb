# -*- encoding : utf-8 -*-
require 'date'
require 'digest/md5'

def read_header line
	#puts "read_header (#{line})"
	header = Hash.new
	header[:cu] = line[/^[^:]+: ([0-9]+),.*$/, 1]
	header
end




@@nazev_uctu = ARGV[0]
@@header = nil
@@records = Array.new

@@file_out = ARGV[1]

if ARGV.length != 2
	puts "Usage: ruby txt2gpc NAZEV_UCTU outfile_name.gpc"
	exit -1
end


puts "reading from STDIN, writting to #{@@file_out}, nazev uctu: [#{@@nazev_uctu}]"


#otevrit vstup - stdin?
#cist radku po radce
current_record = nil
STDIN.read.split("\n").each do |line|
	
	#nacist header
 	if @@header.nil?
 		@@header = read_header line
 		next
 	end

#nacitat zbytek - zaznamy radek po radce, oddelene prazdnymi radkami
	#puts "line len: " + line.length.to_s
	if line.length == 1 && line === "\r"
		#puts "empty line"
		current_record = Hash.new
		@@records << current_record
	end


#nacist datum operace
	current_record[:datum_operace] = line[/^datum zaúčtování:[^0-9]+(.*).$/,1] if line =~ /^datum zaúčtování:.*$/
#castka
	current_record[:castka] = line[/^částka: +([^ ]+).$/, 1] if line =~ /^částka:.*$/
#mena
	current_record[:mena] = line[/^měna: +([A-Za-z]+).$/, 1] if line =~ /^měna:.*$/
#zustatek
	current_record[:zustatek] = line[/^zůstatek: +([^ ]*).$/, 1] if line =~/^zůstatek:.*$/
#ks
	current_record[:ks] = line[/^konstantní symbol: +([^ ]*).$/, 1] if line =~ /^konstantní symbol:.*$/
#vs
	current_record[:vs] = line[/^variabilní symbol: +([^ ]*).$/, 1] if line =~ /^variabilní symbol:.*$/
#ss
	current_record[:ss] = line[/^specifický symbol: +([^ ]*).$/, 1] if line =~ /^specifický symbol:.*$/
#oznaceni operace
	current_record[:oznaceni_operace] = line[/^označení operace: +([^ ].*).$/, 1] if line =~ /^označení operace:.*$/
#protiucet - nazev
	current_record[:nazev_protiuctu] = line[/^název protiúčtu: +([^ ].*).$/, 1] if line =~ /^název protiúčtu:.*$/
#protiucet - cislo
	current_record[:protiucet] = line[/^protiúčet: +([^ ].*).$/, 1] if line =~ /^protiúčet:.*$/
#poznamka
	current_record[:poznamka] = line[/^poznámka: +([^ ].*).$/, 1] if line =~ /^poznámka:.*$/
#prazdne radky - ukonceni zaznamu
end

puts "cislo uctu: #{@@header[:cu]}"

oldest = nil
newest = nil

@@records.each do |record|
	record[:poznamka] = '' if record[:poznamka].nil?
	record[:poznamka] = record[:poznamka].gsub /\s+/, ' '

	record[:date] = Date.strptime record[:datum_operace], '%d.%m.%Y'

	record[:nazev_protiuctu] = "" if record[:nazev_protiuctu].nil?
	record[:protiucet] = '' if record[:protiucet].nil?

	record[:record_id] = @@header[:cu] + record[:protiucet] + record[:datum_operace] + record[:castka] + 
	             record[:mena] + record[:vs] + record[:nazev_protiuctu] + record[:oznaceni_operace]  + record[:zustatek]

	record[:hash] = Digest::SHA256.hexdigest(record[:record_id]).hex().to_s(10)[0..12]

	d = record[:date]

	record[:ddmmyy] = d.strftime '%d%m%y'

	if oldest.nil? or d < oldest
		oldest = d
	end

	if newest.nil? or d > newest
		newest = d
	end
end

puts "oldest date #{oldest}, newest #{newest}"

@@records.sort! {|a, b| a[:date] <=> b[:date]}

@@records.each do |record|
	d = record[:date]


	puts "record: date #{record[:datum_operace]} [#{record[:ddmmyy]}], castka #{record[:castka]} #{record[:mena]} zustatek #{record[:zustatek]} ks: [#{record[:ks]}] vs: [#{record[:vs]}] ss: [#{record[:ss]}]"
	puts "protiucet: [#{record[:protiucet]}] oznaceni [#{record[:oznaceni_operace]}], nazev_protiuctu [#{record[:nazev_protiuctu]}], poznamka [#{record[:poznamka]}]"
	puts "recordId [#{record[:record_id]}] [#{record[:hash]}]"
end



ddmmyy =  oldest.strftime '%d%m%y' 
stary_zustatek = "0".rjust 14, '0'
stary_zustatek_znamenko = '+'
novy_zustatek = stary_zustatek
novy_zustatek_znamenko = '+'
obraty_debet = stary_zustatek
obraty_debet_znak = '0' #muze byt '0' nebo '-'
obraty_kredit = stary_zustatek
obraty_kredit_znak = obraty_debet_znak
datum_vyuctovani = newest.strftime '%d%m%y'
por_cislo_vypisu = '000'
pad = 'CSOB'.ljust(14, ' ')
CRLF="\r\n"
gpc_header  = "074" + @@header[:cu].rjust(16, '0')  + @@nazev_uctu.rjust(20, ' ') +
          ddmmyy+stary_zustatek + stary_zustatek_znamenko+ novy_zustatek + novy_zustatek_znamenko+ 
          obraty_debet + obraty_debet_znak + obraty_kredit + obraty_kredit_znak + por_cislo_vypisu + 
          datum_vyuctovani + pad + CRLF

puts "GPC:"
puts "====================================="
#puts "074#{@@header[:cu].rjust(16, '0')}#{@@nazev_uctu.rjust(20, ' ')}#{ddmmyy}#{stary_zustatek}+#{novy_zustatek}+#{obraty_debet}#{obraty_debet_znak}#{obraty_kredit}#{obraty_kredit_znak}#{por_cislo_vypisu}#{datum_vyuctovani}"
puts "#{gpc_header}"

if gpc_header.length != 130
	puts "header has invalid length " + gpc_header.length
	exit -1
end


f = File.open(@@file_out, 'w')

f.write gpc_header

@@records.each do |record|
	
	protiucet_cislo = record[:protiucet][/^([0-9]+)\//, 1]
	protiucet_cislo = '' if protiucet_cislo.nil?

	protiucet_kod_banky = record[:protiucet][/^[0-9]+\/([0-9]+)$/, 1]
	protiucet_kod_banky = '' if protiucet_kod_banky.nil?

	castka = record[:castka][/-?([0-9\.]+)$/, 1].gsub('.', '').rjust(12, '0')

	debet_kredit = '2' 
	debet_kredit = '1' if record[:castka][0] === '-'

	vs = record[:vs].rjust(10, '0')
	ks = record[:ks].rjust(4, '0')
	ss = record[:ss].rjust(10, '0')
	
	popis = record[:poznamka] + record[:nazev_protiuctu] + " "+record[:oznaceni_operace]
	popis = popis.unpack("U*").map{|c|c.chr rescue '_' }.join
	popis = popis.ljust(20, ' ')[0..19]
	mena  = '0203'
	record_line = "075" + @@header[:cu].rjust(16, '0')  + protiucet_cislo.rjust(16, '0') + record[:hash] + castka + debet_kredit + vs + protiucet_kod_banky.rjust(6, '0') + ks + ss + record[:ddmmyy] + popis + "0" + mena + record[:ddmmyy] + CRLF


	puts "#{record_line}"

	if gpc_header.length != 130
		puts "record has invalid length " + gpc_header.length
		exit -1
	end


	f.write record_line



end

f.close

puts "====================================="

puts "#{@@file_out} wrote OK"