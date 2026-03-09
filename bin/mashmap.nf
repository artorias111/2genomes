process SKETCH_ALIGN {
    input:
    path ref_scaffolds
    path query_scaffolds

    output:
    path "mashmap_out.txt", emit: mashmap_out
    path "circos_links.txt", emit: circos_links


    script:
    """
    {params.mashmap_dir}/mashmap -r ${ref_scaffolds} \
    -q ${query_scaffolds} \
    -t ${params.nthreads} \
    -s ${params.segment_length} \
    --pi ${params.percent_identity} \
    -f one-to-one \
    -o mashmap_out.txt

    awk '{print \$6, \$8, \$9, \$1, \$3, \$4}' mashmap_out.txt > circos_links.txt
    """
}