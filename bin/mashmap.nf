process SKETCH_ALIGN {
    input:
    path ref_scaffolds
    path query_scaffolds

    output:
    path "mashmap_out.txt", emit: mashmap_out

    script:
    """
    ${params.mashmap_path}/mashmap \
        -r ${ref_scaffolds} \
        -q ${query_scaffolds} \
        -t ${params.nthreads} \
        -s ${params.segment_length} \
        --pi ${params.percent_identity} \
        -f one-to-one \
        -o mashmap_out.txt
    """
}
