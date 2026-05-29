#!/usr/bin/env python3
"""
Convert MashMap output to Circos link format.
Links inherit the color of the ref chromosome they originate from,
with transparency (_a4) so overlapping links remain readable.
"""

import sys
import argparse


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mashmap",   required=True)
    parser.add_argument("--karyotype", required=True)
    parser.add_argument("--ref_id",    required=True)
    parser.add_argument("--query_id",  required=True)
    parser.add_argument("--min_size",  type=int, default=50000,
                        help="Minimum link size in bp (default: 50000)")
    args = parser.parse_args()

    # Build ref-chrom → color map from karyotype
    chr_colors = {}
    with open(args.karyotype) as fh:
        for line in fh:
            parts = line.strip().split()
            if len(parts) < 7:
                continue
            circos_id = parts[2]
            color     = parts[6]
            prefix    = f"{args.ref_id}_"
            if circos_id.startswith(prefix):
                raw_name = circos_id[len(prefix):]
                chr_colors[raw_name] = color

    written = 0
    with open(args.mashmap) as fh:
        for line in fh:
            cols = line.strip().split()
            if len(cols) < 9:
                continue
            qname  = cols[0]
            qstart = int(cols[2])
            qend   = int(cols[3])
            rname  = cols[5]
            rstart = int(cols[7])
            rend   = int(cols[8])

            if (rend - rstart) < args.min_size:
                continue

            color = chr_colors.get(rname, "grey")
            print(f"{args.ref_id}_{rname} {rstart} {rend} "
                  f"{args.query_id}_{qname} {qstart} {qend} "
                  f"color={color}_a4")
            written += 1

    print(f"{written} links written.", file=sys.stderr)


if __name__ == "__main__":
    main()
