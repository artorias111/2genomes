process SKETCH_ALIGN {
    input:
    path ref_genome
    path query_genome

    output:
    path "mashmap_out.txt", emit: mashmap_out

    script:
    """
    ${params.mashmap_path}/mashmap \
        -r ${ref_genome} \
        -q ${query_genome} \
        -t ${params.nthreads} \
        -s ${params.segment_length} \
        --pi ${params.percent_identity} \
        -f one-to-one \
        -o mashmap_out.txt
    """
}
