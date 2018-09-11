import sys


def remove_blanks(seq):
    return "".join(c for c in seq if c != "-")


def cigar(read, ref):
    cigar = ""
    index = 0
    limit = len(read)
    while index < limit:
        if read[index] == "-" and ref[index] == "-":
            index += 1
            continue

        start = index
        letter = None
        if read[index] == "-":
            letter = "D"
            while index < limit and read[index] == "-" and ref[index] != "-":
                index += 1

        elif ref[index] == "-":
            letter = "I"
            while index < limit and ref[index] == "-" and read[index] != "-":
                index += 1

        else:
            letter = "M"
            while index < limit and ref[index] != "-" and read[index] != "-":
                index += 1

        cigar += f"{index - start	}{letter}"

    return cigar


def format_line(idx, read, reference):
    real_read = remove_blanks(read)
    return "\t".join([f"read{idx}", "0",
                      "ref", "1", "60",
                      cigar(read, reference), "*", "0",
                      "0", real_read, "@"*len(real_read)])


def main():
	if len(sys.argv) != 2:
		print("Provide a file name.")
		return

	with open(sys.argv[1]) as file:
		content = file.readlines()

	lines = ["".join(line.split()) for line in content if line.strip()]
	assert len(lines) >= 2, "Provide at least one reference and a read"

	len1 = len(lines[0])
	assert all(len(line) == len1 for line in lines), \
		"The reads and the reference must have the same length"

	valid_chars = set("ACGT-")
	assert all(all(c in valid_chars for c in line)
	           for line in lines), "Invalid characters in data"

	reference = lines.pop()
	with open("ref.fa", "w") as ref_file:
	    ref_file.write(">ref\n")
	    ref_file.write(remove_blanks(reference))
	    ref_file.write("\n")

	SAM_HEADER = f"@HD\tVN:1.4\tSO:coordinate\n@SQ	SN:ref	LN:{len(reference)}\n"
	alignment_data = "\n".join(format_line(idx, read, reference)
	                           for idx, read in enumerate(lines))
	with open("als.sam", "w") as sam_file:
	    sam_file.write(SAM_HEADER)
	    sam_file.write(alignment_data)

main()
