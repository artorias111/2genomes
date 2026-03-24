# 2 Teleost Genomes

Compare your teleost genome against the ancestral 24 chromosomes of the playfish _Xiphophorus maculatus_.

Why platyfish? See https://doi.org/10.1534/genetics.114.164293


## Usage
1. Get the platyfish genome if you don't have it. https://useast.ensembl.org/Xiphophorus_maculatus/Info/Annotation?

2. Gather your contigs/scaffolds. Ideally you should shortlist your scaffolds to the top n chromsomes/scaffolds where n is approximately 90% of the genomes (L90), or roughly about 30 of your longest scaffolds (to prevent overcrowding). Label your headers as you desire, make sure they're unique. 

3. Fill up the config template (copy if from above)


```shell
nextflow run artorias111/2genomes -c config_template
```
