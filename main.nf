nextflow.enable.dsl = 2

include { GENERATE_SAMTOOLS_INDEX as INDEX_REF   } from './bin/helper_scripts.nf'
include { GENERATE_SAMTOOLS_INDEX as INDEX_QUERY } from './bin/helper_scripts.nf'
include { SKETCH_ALIGN                           } from './bin/mashmap.nf'
include { MAKE_KARYOTYPE                         } from './bin/circos.nf'
include { PREFIX_LINKS                           } from './bin/circos.nf'
include { MAKE_CONF                              } from './bin/circos.nf'
include { CIRCOS                                 } from './bin/circos.nf'

workflow {
    ref_ch   = Channel.fromPath(params.ref_genome,   checkIfExists: true)
    query_ch = Channel.fromPath(params.query_genome, checkIfExists: true)

    // Index both genomes and align — all three run in parallel
    fai_ref   = INDEX_REF(ref_ch).index
    fai_query = INDEX_QUERY(query_ch).index
    mashmap   = SKETCH_ALIGN(ref_ch, query_ch).mashmap_out

    // Karyotype uses MashMap output to assign homologous colors to query chromosomes
    karyotype = MAKE_KARYOTYPE(fai_ref, fai_query, mashmap).karyotype

    links = PREFIX_LINKS(mashmap, karyotype).circos_links
    conf  = MAKE_CONF(karyotype)

    CIRCOS(conf, karyotype, links)
}
