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
    python ${projectDir}/bin/generate_karyotype.py \\
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
    LAST_SM=\$(grep "^chr.*${sm}_" ${karyotype} | tail -1 | awk '{print \$4}')
    FIRST_DM=\$(grep "^chr.*${dm}_" ${karyotype} | head -1 | awk '{print \$4}')

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

    output:
    path "circos_links.txt", emit: circos_links

    script:
    def sm = params.ref_id
    def dm = params.query_id
    def min_size = params.min_link_size ?: 5000 
    """
    awk -v min=${min_size} 'BEGIN{OFS=" "} 
    (\$9 - \$8) >= min {
        n=\$6; gsub(/[^0-9]/, "", n); 
        
        print "${sm}_"\$6, \$8, \$9, "${dm}_"\$1, \$3, \$4, "color=chr" n "_a4"
    }' ${mashmap_out}  | sed s'/chr23/chrx/' | sed s'/chr24/chry/' > circos_links.txt
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
