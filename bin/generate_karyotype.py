import argparse
import sys

def generate_circos_karyotype(fai_files, prefixes, color_modes):
    for fai, prefix, color_mode in zip(fai_files, prefixes, color_modes):
        with open(fai, "r") as f:
            for i, line in enumerate(f, start=1):
                fields = line.strip().split("\t")
                chrom_name   = fields[0]
                chrom_length = fields[1]
                circos_id    = f"{prefix}_{chrom_name}"

                # Handle the color mapping logic
                if color_mode == "ref":
                    if i == 23:
                        color = "chrx"
                    elif i == 24:
                        color = "chry"
                    else:
                        color = f"chr{i}"
                else:
                    color = "grey"

                # Print directly to stdout
                print(f"chr - {circos_id} {chrom_name} 0 {chrom_length} {color}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--ref_index',    type=str, required=True)
    parser.add_argument('--query_index',  type=str, required=True)
    parser.add_argument('--ref_prefix',   type=str, required=True)
    parser.add_argument('--query_prefix', type=str, required=True)
    args = parser.parse_args()

    generate_circos_karyotype(
        fai_files    = [args.ref_index,  args.query_index],
        prefixes     = [args.ref_prefix, args.query_prefix],
        color_modes  = ["ref",           "grey"]
    )

    # Status message goes to stderr so it doesn't end up in your karyotype file
    print("karyotype.txt generated successfully to stdout.", file=sys.stderr)
