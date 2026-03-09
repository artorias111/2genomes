process GENERATE_SAMTOOLS_INDEX {
    input:
    path fasta

    output:
    path "${fasta}.fai", emit: index

    script:
    """
    samtools faidx ${fasta}
    """
}