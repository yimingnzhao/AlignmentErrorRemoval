PROGRAM_VERSION = v"0.1.2-alpha"
try
	using ArgParse
catch
	import Pkg
	Pkg.add("ArgParse")
	using ArgParse
end
import Statistics.median

function correction(fin, fout, k, X, MASK, pvalue, pseudocount, verbose)
	inputText = read(fin, String)
	temp = split(inputText, ">")
	temp = temp[length.(temp) .> 0]
	temp = [split(arr, "\n") for arr in temp]
	header = [arr[1] for arr in temp]
	c = [string(arr[2:end]...) for arr in temp]
	upperc = [uppercase(str) for str in c]
	if length(c) == 0
		return
	end
	arrc = [Array{Char, 1}(str) for str in c]
	n = length(c[1])
	m = length(c)
	if n <= k
		print(fout, inputText)
		return
	end
	wo = zeros(n, m)
	# read sequences and compute per column profiles. 
	for i in 1:n
		cnt = zeros(128)
		# read a column, internally represent in upper case, and count letters
		for j in 1:m
			cnt[UInt8(upperc[j][i])] += 1
		end
		cnt[UInt8(X)] = 0
		cnt[UInt8('-')] = 0
		unq = length([1 for t in cnt if t > 0])
		total = sum(cnt)
		for j in 1:m
			wo[i, j] = total == 0 ? 0 : (total + pseudocount) / (unq * cnt[UInt8(c[j][i])])
		end
	end
	w1 = [wo[:,j][(arrc[j] .!= '-') .& (arrc[j] .!= X)] for j in 1:m]
	w = [[median(arr[i:i+k-1]) for i in 1:length(arr)-k+1] for arr in w1]
	ws = [[sum(arr[i:i+k-1]) for i in 1:length(arr)-k+1] for arr in w1]
	wsorted = [sort(arr) for arr in w]
	wsum = [accumulate(+, arr) for arr in wsorted]
	f(x, y, n, m) = x^2 / n + (n == m ? 0 : (y - x)^2 / (m - n))
	var = [length(arr) > 0 ? f.(arr, arr[end], 1:length(arr), length(arr)) : [] for arr in wsum]
	cutoffFloor = min([(i > (pvalue) * length(var[j]) ? wsorted[j][i] : 3) for j in 1:m if length(var[j]) > 0 for i in [findmax(var[j])[2]]]...)
	wCutoff = [length(var[j]) > 0 ? wsorted[j][findmax(var[j])[2]] : 0 for j in 1:m]

	s = zeros(n - k + 1, m, 2)
	tiebreaker = zeros(n - k + 1, m, 2)
	bt = zeros(Int64, n - k + 1, m, 2)
	for j in 1:m
		wj = w[j]
		wsj = ws[j]
		L = length(wj)
		if L <= k
			if verbose
				println(stderr, "Sequence too short for " * header[j] * " after gap removal; correction skipped.")
				println(stderr)
			end
			println(fout, ">" * header[j])
			println(fout, c[j])
			continue
		end
		s = zeros(L)
		bt = zeros(Int64, L, 2)
		cutoff = max(wCutoff[j], cutoffFloor, 1)
		for i in 1:L
			v = (wj[i] > cutoff ? 1 : 0)
			s[i] = v
		end

		for i in 1:L
			
			left_ones = 0
			left_zeros = 0
			right_ones = 0
			right_zeros = 0
			
			ind = i
			ind_k = k
			while ind_k > 0
				if ind == 0 || ind == k 
					break
				end
				if s[ind] == 1
					left_ones += ind_k
				else
					left_zeros += ind_k
				end

				ind -= 1
				ind_k -= 1
			end
			
			ind = i
			ind_k = k
			while ind_k > 0
				if ind == L + 1 || ind == k
					break
				end
				if s[ind] == 1
					right_ones += ind_k
				else
					right_zeros += ind_k
				end

				ind += 1
				ind_k -= 1
			end
		
			bt[i, 1] = (left_zeros >= left_ones) ? 0 : 1
			bt[i, 2] = (right_zeros >= right_ones) ? 0 : 1
			
		end

		str = arrc[j][(arrc[j] .!= '-') .& (arrc[j] .!= X)]
		icur = L
		if s[L] == 1
			str[L:L+k-1] .= MASK
		end
		while icur > 0

			if s[icur] == 0 && bt[icur, 1] == 0 && bt[icur, 2] == 0
				icur -= 1
			elseif s[icur] == 1 && bt[icur, 1] == 1 && bt[icur, 2] == 1
				str[icur] = MASK
				icur -= 1
			elseif s[icur] == 0 && bt[icur, 1] == 1 && bt[icur, 2] == 1
				str[icur] = MASK
				icur -= 1
			elseif s[icur] == 1 && bt[icur, 1] == 0 && bt[icur, 2] == 0
				icur -= 1
			elseif s[icur] == 1
				str[icur] = MASK
				icur -= 1
			elseif s[icur] == 0 
				str[icur] = MASK
				icur -= 1
			end
		end
		println(fout, ">" * header[j])
		strout = ""
		i = 1
		for t in 1:length(c[j])
			if c[j][t] == X || c[j][t] == '-'
				strout *= c[j][t]
			else
				strout *= str[i]
				i += 1
			end
		end
		println(fout, strout)
		if verbose && strout != c[j]
			println(stderr, "Filtered " * header[j] * "; replaced")
			println(stderr, c[j])
			println(stderr, "with")
			println(stderr, strout)
			println(stderr)
		end
	end
end

function ArgParse.parse_item(::Type{Char}, x::AbstractString)
	return x[1]
end

function parse_commandline()
	s = ArgParseSettings()
	
	@add_arg_table s begin
		"--list", "-l"
			help = "running on a list of inputs; for every two lines of the list file, the first one should be the path to the input and the second should be the path to its output"
			action = :store_true
		"--verbose", "-v"
			help = "print more information to standard error"
			action = :store_true
		"--nopseudocount", "-n"
			help = "do not use pseudo-count to remove unaligned regions"
			action = :store_true
		"--mask", "-m"
			help = "the character to mask erroneous regions"
			arg_type = Char
			default = 'X'
		"--any", "-a"
			help = "the character to denote ambiguous positions or character to denote ANY in the input files"
			arg_type = Char
			default = 'X'
		"--k", "-k"
			help = "set k for k-mer"
			arg_type = Int
			default = 7
		"--cutoff", "-c"
			help = "set p-value cutoff to control the minimum aggressiveness of masking"
			arg_type = Float64
			default = 0.05
		"input"
			help = "a fasta file as input (when -l is not set) or a list of input/output pairs (when -l is set)"
			required = true
	end
	
	return parse_args(s)
end

function main()
	println(stderr, "Version " * string(PROGRAM_VERSION))
	args = parse_commandline()
	if args["list"] == false
		correction(open(args["input"], "r"), stdout, args["k"], args["any"], args["mask"], 1 - args["cutoff"], args["nopseudocount"] ? 0 : 1, args["verbose"])
	else
		temp = split(read(open(args["input"], "r"), String), "\n")
		temp = temp[length.(temp) .> 0]
		for i = 2:2:length(temp)
			try
				println(stderr, "Processing " * temp[i - 1] * "...")
				correction(open(temp[i - 1], "r"), open(temp[i], "w"), args["k"], args["any"], args["mask"], 1 - args["cutoff"], args["nopseudocount"] ? 0 : 1, args["verbose"])
			catch
				println(stderr, "Error happened when processing " * temp[i - 1] * ".")
				println(stderr)
			end
		end
	end
end
main()
