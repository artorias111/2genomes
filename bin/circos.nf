process MAKE_KARYOTYPE {
    input:
    path fai_ref   // reference .fai
    path fai_query // query .fai

    output:
    path "karyotype.txt", emit: karyotype

    script:
    def ref_id = params.ref_id
    def query_id = params.query_id

    """
    generate_karyotype.py \\
        --ref_index ${fai_ref} \\
        --query_index ${fai_query} \\
        --ref_prefix ${ref_id} \\
        --query_prefix ${query_id} > karyotype.txt
    """
}

process MAKE_CONF {
    input:
    path karyotype   // needed to extract last ref chr and first query chr for pairwise spacing

    output:
    path "circos.conf"

    script:
    def sm = params.ref_id
    def dm = params.query_id
    """
    LAST_SM=\$(grep "^chr.*${sm}_" ${karyotype} | tail -1 | awk '{print \$3}')
    FIRST_DM=\$(grep "^chr.*${dm}_" ${karyotype} | head -1 | awk '{print \$3}')

    sed \
        -e "s|SM_PREFIX|${sm}_|g" \
        -e "s|LAST_SM_CHR|\${LAST_SM}|g" \
        -e "s|FIRST_DM_CHR|\${FIRST_DM}|g" \
        ${projectDir}/assets/circos_template.conf > circos.conf
    """
}

process PREFIX_LINKS {
    input:
    path mashmap_out
    path karyotype

    output:
    path "circos_links.txt", emit: circos_links

    script:
    def sm = params.ref_id
    def dm = params.query_id
    def min_size = params.min_link_size ?: 5000 
    """
    process_links.py \\
        --mashmap ${mashmap_out} \\
        --karyotype ${karyotype} \\
        --ref_id ${sm} \\
        --query_id ${dm} \\
        --min_size ${min_size} > circos_links.txt
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
    circos -conf ${circos_conf} \
        -param karyotype=${karyotype} \
        -param links/link/file=${circos_links}
    """
}
