process MAKE_KARYOTYPE {
    input:
    path fai_ref
    path fai_query
    path mashmap_out

    output:
    path "karyotype.txt", emit: karyotype

    script:
    def ref_id   = params.ref_id
    def query_id = params.query_id
    """
    generate_karyotype.py \
        --ref_index   ${fai_ref} \
        --query_index ${fai_query} \
        --ref_prefix  ${ref_id} \
        --query_prefix ${query_id} \
        --mashmap     ${mashmap_out} > karyotype.txt
    """
}

process MAKE_CONF {
    input:
    path karyotype

    output:
    path "circos.conf"

    script:
    def ref_id   = params.ref_id
    def query_id = params.query_id
    """
    LAST_REF=\$(grep "^chr.*${ref_id}_" ${karyotype} | tail -1 | awk '{print \$3}')
    FIRST_QRY=\$(grep "^chr.*${query_id}_" ${karyotype} | head -1 | awk '{print \$3}')

    sed \
        -e "s|REF_PREFIX|${ref_id}_|g" \
        -e "s|LAST_REF_CHR|\${LAST_REF}|g" \
        -e "s|FIRST_QRY_CHR|\${FIRST_QRY}|g" \
        -e "s|REF_LABEL|${ref_id}|g" \
        -e "s|QRY_LABEL|${query_id}|g" \
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
    def ref_id   = params.ref_id
    def query_id = params.query_id
    def min_size = params.min_link_size ?: 50000
    """
    process_links.py \
        --mashmap   ${mashmap_out} \
        --karyotype ${karyotype} \
        --ref_id    ${ref_id} \
        --query_id  ${query_id} \
        --min_size  ${min_size} > circos_links.txt
    """
}

process CIRCOS {
    conda params.circos_env

    publishDir "${params.outdir ?: 'results'}", mode: 'copy'

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
