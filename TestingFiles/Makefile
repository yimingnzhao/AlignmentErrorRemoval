clean: 
	-rm -f *.fasta 2> /dev/null
	-rm -f OUTPUT 2> /dev/null


julia:
	julia correction.jl -k 11 -n -m X -a N error.fasta > OUTPUT


error:
	python getErrorRates.py position.fasta error.fasta OUTPUT test
