# 2 Genomes → Circos

A minimal Nextflow workflow that takes **two chromosome-level genome FASTAs** and produces a synteny circos plot. No hardcoded species — compare any two genomes.

```
Input:  genome_A.fasta  +  genome_B.fasta
Output: circos.png  +  circos.svg
```

## How it works

1. Both genomes are indexed with `samtools faidx`
2. [MashMap](https://github.com/marbl/MashMap) finds syntenic blocks between the two genomes
3. A karyotype is generated with **smart homology coloring**:
   - Each reference chromosome gets a distinct color
   - Each query chromosome is colored to match its most syntenic ref chromosome
   - If a ref chromosome was split across query scaffolds, all fragments share the same color
   - Unanchored query chromosomes are colored grey
4. [Circos](http://circos.ca) renders the final plot with scale ticks (10/50 Mb)

## Requirements

- [Nextflow](https://www.nextflow.io/) ≥ 22
- [samtools](https://www.htslib.org/) (in PATH or conda env)
- [MashMap](https://github.com/marbl/MashMap) — set path in config
- [Circos](http://circos.ca) — set conda env in config

## Usage

**1. Copy and fill in the config template:**

```shell
cp config_template my_run.config
# edit my_run.config — set ref_genome, query_genome, ref_id, query_id, tool paths
```

**2. Run:**

```shell
nextflow run artorias111/2genomes -c my_run.config
```

Results land in `results/circos.png` and `results/circos.svg`.

## Config options

| Parameter | Description | Default |
|---|---|---|
| `ref_genome` | Path to reference FASTA (chromosome-level) | — |
| `query_genome` | Path to query FASTA (chromosome-level) | — |
| `ref_id` | Short label prefix for ref chromosomes in plot | — |
| `query_id` | Short label prefix for query chromosomes in plot | — |
| `mashmap_path` | Path to MashMap `bin/` directory | — |
| `circos_env` | Path to Circos conda environment | — |
| `min_link_size` | Min synteny block size to draw (bp) | 50000 |
| `segment_length` | MashMap segment length | 10000 |
| `percent_identity` | Min % identity for MashMap hits | 75 |
| `nthreads` | Threads for MashMap | 8 |

Increase `percent_identity` to 90+ for closely related species. Raise `min_link_size` to reduce visual clutter for highly syntenic genomes.

## Visualizing karyotype evolution against the ancestral teleost karyotype (Xmac)

The platyfish _Xiphophorus maculatus_ (Xmac) carries the ancestral 24-chromosome teleost karyotype, making it an ideal reference for tracking chromosome fusions, fissions, and translocations across teleost species. Using Xmac as `ref_genome` assigns each of the 24 ancestral linkage groups a distinct color; your genome's chromosomes then inherit those colors based on synteny, immediately revealing which ancestral chromosomes fused, split, or remained intact.

**1. Download the Xmac genome from Ensembl:**

```shell
# Example — check https://useast.ensembl.org/Xiphophorus_maculatus for the current release
wget https://ftp.ensembl.org/pub/current_fasta/xiphophorus_maculatus/dna/Xiphophorus_maculatus.X_maculatus-5.0-male.dna.toplevel.fa.gz
gunzip Xiphophorus_maculatus.X_maculatus-5.0-male.dna.toplevel.fa.gz
```

**2. Config for an Xmac comparison:**

```
params.ref_genome        = "/path/to/Xiphophorus_maculatus.toplevel.fa"
params.query_genome      = "/path/to/your_genome.fasta"
params.ref_id            = "Xm"
params.query_id          = "YourSp"
params.percent_identity  = 75   # lower tolerance needed for distant teleosts
params.min_link_size     = 50000
```

**3. Run as usual:**

```shell
nextflow run artorias111/2genomes -c my_run.config
```

In the output plot, chromosomes of the same color share ancestry. A query chromosome that is a single solid color likely represents an intact ancestral linkage group; one that is grey has no detectable synteny to any Xmac chromosome (may be a sex chromosome or highly rearranged region). See [Pennell et al. 2015](https://doi.org/10.1534/genetics.114.164293) for the biological rationale behind using Xmac as an ancestral karyotype reference.

---

## Tips

- **Chromosome-level assemblies work best.** If using a scaffold-level assembly, pre-filter to your L90 scaffolds (the top ~N longest scaffolds covering 90% of the genome) to avoid an overcrowded plot.
- **Keep `ref_id` and `query_id` short** (2–4 characters) — they appear as chromosome label prefixes.
- The color palette supports up to 50 distinct ref chromosomes. Colors cycle beyond that.
