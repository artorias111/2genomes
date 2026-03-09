nextflow.enable.dsl=2

include { GENERATE_SAMTOOLS_INDEX } from './bin/helper_scripts.nf'
include { SKETCH_ALIGN           } from './bin/mashmap.nf'
include { MAKE_KARYOTYPE; CIRCOS } from './bin/circos.nf'


workflow {
    /*
     * Input genome FASTA files
     */
    Channel
        .fromPath(params.ref_scaffolds)
        .set { ch_ref_fasta }

    Channel
        .fromPath(params.query_scaffolds)
        .set { ch_query_fasta }

    /*
     * Index genomes
     */
    ref_index_ch = GENERATE_SAMTOOLS_INDEX(ch_ref_fasta).index
    query_index_ch = GENERATE_SAMTOOLS_INDEX(ch_query_fasta).index

    /*
     * Mashmap alignment and Circos links
     */
    mashmap_results = SKETCH_ALIGN(ch_ref_fasta, ch_query_fasta)
    links_ch = mashmap_results.circos_links

    /*
     * Karyotype from indices
     */
    karyotype_ch = MAKE_KARYOTYPE(ref_index_ch, query_index_ch).karyotype

    /*
     * Circos plot
     *
     * The Circos config (params.circos_conf) should reference
     * karyotype.txt and circos_links.txt in its plots.
     */
    conf_ch = Channel.fromPath(params.circos_conf)

    circos_out = CIRCOS(conf_ch, karyotype_ch, links_ch)

    circos_out.circos_png.view { "Circos PNG: ${it}" }
    circos_out.circos_svg.view { "Circos SVG: ${it}" }
}