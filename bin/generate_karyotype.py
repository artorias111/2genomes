import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--ref_index', type = str, required = True)
parser.add_argument('--query_index', type = str, required = True)

parser.add_argument('--query_prefix', type = str, required = True)
parser.add_argument('--ref_prefix', type = str, required = True)

args = parser.parse_args()

ref_index = args.ref_index
query_index = args.query_index

ref_prefix = args.ref_prefix
query_prefix = args.query_prefix


def generate_circos_karyotype(fai_files, prefixes, colors):
    with open("karyotype.txt", "w") as out_f:
        for fai, prefix, color in zip(fai_files, prefixes, colors):
            with open(fai, "r") as f:
                for line in f:
                    fields = line.strip().split("\t")
                    chrom_name = fields[0]
                    chrom_length = fields[1]
                    
                    circos_id = f"{prefix}_{chrom_name}"
                    
                    out_line = f"chr - {circos_id} {chrom_name} 0 {chrom_length} {color}\n"
                    out_f.write(out_line)

fai_list = [ref_index, query_index]
prefix_list = [ref_prefix, query_prefix]
color_list = ["chr1", "grey"] # Color Xmac by standard palette, Dmaw as grey for contrast

generate_circos_karyotype(fai_list, prefix_list, color_list)
print("karyotype.txt generated successfully.")