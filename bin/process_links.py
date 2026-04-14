#!/usr/bin/env python3
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description="Process MashMap output for Circos links.")
    parser.add_argument("--mashmap", required=True, help="MashMap output file")
    parser.add_argument("--karyotype", required=True, help="Karyotype file")
    parser.add_argument("--ref_id", required=True, help="Reference ID")
    parser.add_argument("--query_id", required=True, help="Query ID")
    parser.add_argument("--min_size", type=int, default=5000, help="Minimum link size")

    args = parser.parse_args()

    # Read karyotype to map reference chromosomes to their colors
    chr_colors = {}
    with open(args.karyotype, "r") as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 7:
                # chr - circos_id label start end color
                # Example: chr - Xm_chr1 chr1 0 100000 chr1
                circos_id = parts[2]
                color = parts[6]
                if circos_id.startswith(f"{args.ref_id}_"):
                    ref_chrom = circos_id[len(f"{args.ref_id}_"):]
                    chr_colors[ref_chrom] = color

    with open(args.mashmap, "r") as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 9:
                query_name = parts[0]
                query_start = int(parts[2])
                query_end = int(parts[3])
                ref_name = parts[5]
                ref_start = int(parts[7])
                ref_end = int(parts[8])

                link_size = ref_end - ref_start
                if link_size >= args.min_size:
                    color = chr_colors.get(ref_name, "grey")
                    print(f"{args.ref_id}_{ref_name} {ref_start} {ref_end} {args.query_id}_{query_name} {query_start} {query_end} color={color}_a4")

if __name__ == "__main__":
    main()
