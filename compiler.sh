#!/bin/bash

if [ $# -ne 1 ]
then
	echo "No arguments given"
	echo 
	echo "Usage:"
	echo "./compiler.sh asm_file"
	exit 1
fi

if [ ! -f $asm_file ]
then
	echo -n $asm_file
	echo " does not exist"
fi

# Remove tmp file if it exists
if [ -f tmp ]
then
	rm tmp
fi

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing

# Create a tmp file
touch tmp

# Iterate over the asm file removing useless characters
for i in $(cat < "$1"); do
	treated_input=$(echo $i | sed "s/[',', '(']/ /g" | sed "s/[';',')']//g" | sed "s/0x//g" | tr -s " ")
	if [ $treated_input != "" ] && [ $(echo $treated_input | head -c 1) != "#" ]
	then
		echo $treated_input >> tmp
	fi
done

# Replace tags with addresses
address=0
for i in $(cat < tmp); do
	opcode=$(echo $i | cut -d' ' -f1)
	# Check if this line is a tag
	if [ $(echo $i | grep -o ':' | wc -c) -gt 0 ]
	then
		touch tmp2
		tag=$(echo $i | cut -d' ' -f1 | sed "s/://g")
		for j in $(cat < tmp); do

			# This comparison aims to remove the Tag definition
			# and inserts the address in decimal value
			if [ $j != $i ]
			then
				echo $j | sed "s/ ${tag}$/ $address/g" >> tmp2
			fi
		done
		rm tmp
		mv tmp2 tmp
	elif [ $opcode == "la" ] || [ $opcode == "li" ]
	then
		address=$(( $address+8 ))
	elif [ $(echo $opcode | head -c 1) != "." ] || [ $opcode == ".word" ]
	then
		address=$(( $address+4 ))
	fi
done

# Finally replace each of the remaining instructions to Hexadecimal
touch tmp2

# Used for instructions like JMP, that use imm as relative to PC
address=0

for i in $(cat < tmp); do
	opcode=$(echo $i | cut -d' ' -f1)
	case "$opcode" in
		"la")
			# LUI
			imm=$(echo $i | cut -d' ' -f3)
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ($imm >> 12 << 12) + ( $rd << 7 ) + 55))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			# ADDI
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rd << 15) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"li")
			# LUI
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f3)" | bc)
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( $imm >> 12 << 12) + ( $rd << 7 ) + 55))
			if [ $(( $imm % (1 << 12) )) -ge 2048 ]
			then
				inst=$(( $inst + (1 << 12)))
				# Avoid 33b length instruction (which happens with li 0xFFFFFFFF)
				inst=$(( $inst % (1 << 32)))
			fi
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rd << 15) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"add")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"or")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 6 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"xor")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 4 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"slt")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 2 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sltu")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 3 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"and")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 7 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sll")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 1 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"srl")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 5 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sra")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			inst=$(( ( 1 << 30 ) + ( $rs2 << 20 ) + ( $rs1 << 15 ) + ( 5 << 12 ) + ( $rd << 7 ) + 51))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"lb")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ($imm << 20) + ($rs1 << 15) + ($rd << 7) + 3))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"lh")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ($imm << 20) + ($rs1 << 15) + (1 << 12) + ($rd << 7) + 3))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;

		"lw")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ($imm << 20) + ($rs1 << 15) + (2 << 12) + ($rd << 7) + 3))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"lbu")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ($imm << 20) + ($rs1 << 15) + (4 << 12) + ($rd << 7) + 3))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"lhu")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ($imm << 20) + ($rs1 << 15) + (5 << 12) + ($rd << 7) + 3))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sb")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ( ($imm >> 5) << 25) + ($rs2 << 20) + ($rs1 << 15) + ( ($imm % (1 << 5)) << 7 ) + 35))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sh")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ( ($imm >> 5) << 25) + ($rs2 << 20) + ($rs1 << 15) + (1 << 12) + ( ($imm % (1 << 5)) << 7 ) + 35))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sw")
			# Take into account that the offset can be negative
			negative_offset=0
			if [[ $i == *"-"* ]]
			then
				negative_offset=1
				i=$(echo $i | sed "s/-//g")
			fi
			rs1=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			if [ $negative_offset -eq 1 ]
			then
				imm=$((4096 - $imm))
			fi
			inst=$(( ( ($imm >> 5) << 25) + ($rs2 << 20) + ($rs1 << 15) + (2 << 12) + ( ($imm % (1 << 5)) << 7 ) + 35))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"addi")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"ori")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 6 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"xori")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 4 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"sltiu")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 3 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"slti")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 2 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"andi")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 7 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"slli")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 1 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"srli")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 5 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"srai")
			imm=$(echo "ibase=16; $(echo $i | cut -d' ' -f4)" | bc)
			rs1=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			inst=$(( ( 1 << 30 ) + ( ($imm % (1 << 12) ) << 20 ) + ($rs1 << 15) + ( 5 << 12 ) + ($rd << 7) + 19))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"jal")
			imm=$(echo $i | cut -d' ' -f3)
			rd=$(echo $i | cut -d' ' -f2 | sed "s/x//g")

			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi

			inst=$(( ( ( ($dest >> 19) % 2) << 31 ) + ( ( $dest % ( 1 << 10 ) ) << 21 ) + ( ( ( $dest >> 9 ) % 2 ) << 20 ) + ( ( ( $dest >> 10 ) % ( 1 << 8 ) ) << 12 ) + ( $rd << 7 ) + 111 ))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"bne")
			rs1=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi
			inst=$(( ( ( ($dest >> 11) % 2 ) << 31 ) + ( ( ( $dest >> 4 ) % ( 1 << 6 ) ) << 25 ) + ($rs2 << 20) + ($rs1 << 15) + (1 << 12) + ( ( $dest % ( 1 << 4 ) ) << 8 ) + ( ( ($dest >> 10) % 2) << 7) + 99))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"beq")
			rs1=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi
			inst=$(( ( ( ($dest >> 11) % 2 ) << 31 ) + ( ( ( $dest >> 4 ) % ( 1 << 6 ) ) << 25 ) + ($rs2 << 20) + ($rs1 << 15) + (0 << 12) + ( ( $dest % ( 1 << 4 ) ) << 8 ) + ( ( ($dest >> 10) % 2) << 7) + 99))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"bge")
			rs1=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi
			inst=$(( ( ( ($dest >> 11) % 2 ) << 31 ) + ( ( ( $dest >> 4 ) % ( 1 << 6 ) ) << 25 ) + ($rs2 << 20) + ($rs1 << 15) + (5 << 12) + ( ( $dest % ( 1 << 4 ) ) << 8 ) + ( ( ($dest >> 10) % 2) << 7) + 99))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"bgeu")
			rs1=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi
			inst=$(( ( ( ($dest >> 11) % 2 ) << 31 ) + ( ( ( $dest >> 4 ) % ( 1 << 6 ) ) << 25 ) + ($rs2 << 20) + ($rs1 << 15) + (7 << 12) + ( ( $dest % ( 1 << 4 ) ) << 8 ) + ( ( ($dest >> 10) % 2) << 7) + 99))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"blt")
			rs1=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi
			inst=$(( ( ( ($dest >> 11) % 2 ) << 31 ) + ( ( ( $dest >> 4 ) % ( 1 << 6 ) ) << 25 ) + ($rs2 << 20) + ($rs1 << 15) + (4 << 12) + ( ( $dest % ( 1 << 4 ) ) << 8 ) + ( ( ($dest >> 10) % 2) << 7) + 99))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"bltu")
			rs1=$(echo $i | cut -d' ' -f2 | sed "s/x//g")
			rs2=$(echo $i | cut -d' ' -f3 | sed "s/x//g")
			imm=$(echo $i | cut -d' ' -f4 | sed "s/x//g")
			# >> 1 is used because the destination has to be represented as a 
			# multiple of 2
			dest=$(( ($imm - $address - 4) >> 1 ))
			if [ $dest -lt 0 ] 
			then
				# So as to represent negatives correctly
				dest=$(( $dest + (1 << 20)))
			fi
			inst=$(( ( ( ($dest >> 11) % 2 ) << 31 ) + ( ( ( $dest >> 4 ) % ( 1 << 6 ) ) << 25 ) + ($rs2 << 20) + ($rs1 << 15) + (6 << 12) + ( ( $dest % ( 1 << 4 ) ) << 8 ) + ( ( ($dest >> 10) % 2) << 7) + 99))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		"system")
			inst=$((115))
			echo "obase=16; $inst" | bc >> tmp2
			address=$(( $address+4 ))
			;;
		".word")
			echo $i | cut -d' ' -f2 | cut -d'x' -f2 >> tmp2
			address=$(( $address+4 ))
			;;
		*)
			;;
	esac
done

cat tmp2

mv tmp2 tmp
touch tmp2
for i in $(cat < tmp); do
	echo -n "X\"" >> tmp2
	# Fill with 0s so that every instruction is 8 hexa chars long
	iterations=$(( 9 - $( echo $i | wc -c)))
	while [ $iterations -ne 0 ]
	do
		echo -n "0" >> tmp2
		iterations=$(($iterations - 1))
	done
	echo "$i\"" >> tmp2
done

mv tmp2 tmp

# Preparing the syntax to insert in the memory file
touch tmp2

# Space in memory left. This variable is used to fill the memory up with X"00000000".
left=127

echo -n "signal RAM : memory := (" >> tmp2
for i in $(cat < tmp)
do
	if [ $left -ne 0 ]
	then
		echo -n "$i, " >> tmp2
	else
		echo -n "$i" >> tmp2
	fi
	left=$(($left - 1))
done

while [ $left -ge 0 ]
do 
	if [ $left -ne 0 ]
	then
		echo -n "X\"00000000\"," >> tmp2
	else
		echo -n "X\"00000000\"" >> tmp2
	fi
	left=$(($left - 1))
done
echo -n ");" >> tmp2

mv tmp2 tmp

# Create a new memory file with the new instructions
cat src/memory.vhdl | sed "s/signal RAM.*$/$(cat tmp)/g" > src/memory2.vhdl

# Replace the original memory with the new one
mv src/memory2.vhdl src/memory.vhdl

# Remove useless temporary files
rm tmp
