
import Statistics.median

k = 1
X = 'X'
pseudocount = 0
pvalue = 0.05
verbose = true
fin = open( "27.fasta", "r" )
fout = stdout
MASK = 'X'

inputText = read( fin, String )

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



#println( "header:" )
#println( header )
#println()
#println("c:")
#println( c )
#println()
#println( "arrc: " )
#println( arrc )
#println()




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



#println("wo")
#println( wo )
#println()
#println("w1")
#println( w1 )
#println()
#println("w")
#println( w )
#println()
#println("ws")
#println( ws )
#println()
#println("wsorted")
#println( wsorted )
#println()
#println("wsum")
#println( wsum )
#println()





f(x, y, n, m) = x^2 / n + (n == m ? 0 : (y - x)^2 / (m - n))
var = [length(arr) > 0 ? f.(arr, arr[end], 1:length(arr), length(arr)) : [] for arr in wsum]
cutoffFloor = min([(i > (1 - pvalue) * length(var[j]) ? wsorted[j][i] : 3) for j in 1:m if length(var[j]) > 0 for i in [findmax(var[j])[2]]]...)
cutoffFloor = max(cutoffFloor, 1 + pseudocount * 5 / 12)
wCutoff = [length(var[j]) > 0 ? wsorted[j][findmax(var[j])[2]] : 0 for j in 1:m]




#println( "var" )
#println( var )
#println()
#println( "cutoffFloor" )
#println( cutoffFloor )
#println()
#println( "wCutoff" )
#println( wCutoff )
#println()
#
println(cutoffFloor );

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
	s = zeros(L, 2)
	tiebreaker = zeros(L, 2)
	bt = zeros(Int64, L, 2)
	cutoff = max(wCutoff[j], cutoffFloor, 1)
	for i in 1:L
		v = (wj[i] > cutoff ? 0 : 1)
		if i == 1
			s[i, 1] = v
			s[i, 2] = 1 - v
			tiebreaker[i, 1] = 0
			tiebreaker[i, 2] = wsj[i]
			

#
#			if j == 1
#				println( "s" )
#				println( s )
#				println()
#				println( "tiebreaker" )
#				println( tiebreaker )
#				println()
#				println( "bt" )
#				println( bt )
#				println()
#			end
#
			
		else
			s[i, 1] = s[i - 1, 1] + v
			s[i, 2] = s[i - 1, 2] + 1 - v
			tiebreaker[i, 1] = tiebreaker[i - 1, 1]
			tiebreaker[i, 2] = tiebreaker[i - 1, 2] + wsj[i]
			bt[i, 1] = 1
			bt[i, 2] = 2


#			if j == 1
#				println( "s" )
#				println( s )
#				println()
#				println( "tiebreaker" )
#				println( tiebreaker )
#				println()
#				println( "bt" )
#				println( bt )
#				println()
#			end




		end
		if i > k && (s[i, 1], tiebreaker[i, 1]) < (s[i - k, 2] + v, tiebreaker[i - k, 2])
			s[i, 1] = s[i - k, 2] + v
			tiebreaker[i, 1] = tiebreaker[i - k, 2]
			bt[i, 1] = 2




#			if j == 1
#				println( "s" )
#				println( s )
#				println()
#				println( "tiebreaker" )
#				println( tiebreaker )
#				println()
#				println( "bt" )
#				println( bt )
#				println()
#			end



		end
		if i > k && (s[i, 2], tiebreaker[i, 2]) < (s[i - k, 1] + 1 - v, tiebreaker[i - k, 1])
			s[i, 2] = s[i - k, 1] + 1 - v
			tiebreaker[i, 2] = tiebreaker[i - k, 1] + wsj[i]
			bt[i, 2] = 1



#			if j == 1
#				println( "s" )
#				println( s )
#				println()
#				println( "tiebreaker" )
#				println( tiebreaker )
#				println()
#				println( "bt" )
#				println( bt )
#				println()
#			end
#

		end
	end


#	if j == 1
#		println( "s" )
#		println( s )
#		println()
#		println( "tiebreaker" )
#		println( tiebreaker )
#		println()
#		println( "bt" )
#		println( bt )
#		println()
#	end
#	if j == 4
#		println( "s" )
#		println( s )
#		println()
#		println( "tiebreaker" )
#		println( tiebreaker )
#		println()
#		println( "bt" )
#		println( bt )
#		println()
#	end
#


	str = arrc[j][(arrc[j] .!= '-') .& (arrc[j] .!= X)]
	icur = L
	if s[L, 1] < s[L, 2]
		str[L:L+k-1] .= MASK
		bcur = 2
	else
		bcur = 1
	end
	while true
		if bcur == 1 && bt[icur, bcur] == 1
			icur -= 1
			bcur = 1
		elseif bcur == 1 && bt[icur, bcur] == 2
			icur -= k
			bcur = 2
			str[icur : icur + k - 1] .= MASK
		elseif bcur == 2 && bt[icur, bcur] == 1
			icur -= k
			bcur = 1
		elseif bcur == 2 && bt[icur, bcur] == 2
			icur -= 1
			bcur = 2
			str[icur] = MASK
		elseif bcur == 1
			break
		else
			str[1:icur - 1] .= MASK
			break
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
