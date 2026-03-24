process MAKE_KARYOTYPE {
    input:
    path fai_ref   // reference .fai
    path fai_query // query .fai

    output:
    path "karyotype.txt", emit: karyotype

    script:
    def sm = params.ref_id
    def dm = params.query_id

    """
    python ${projectDir}/bin/generate_karyotype.py \\
        --ref_index ${fai_ref} \\
        --query_index ${fai_query} \\
        --ref_prefix ${sm} \\
        --query_prefix ${dm}
    """
}

process CIRCOS {
    conda params.circos_env

    input:
    path circos_conf
    path karyotype
    path circos_links

    output:
    path "circos.png", emit: circos_png
    path "circos.svg", emit: circos_svg

    script:
    """
    circos -conf ${circos_conf}
    """
}
