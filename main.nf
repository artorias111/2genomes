nextflow.enable.dsl = 2

include { GENERATE_SAMTOOLS_INDEX as GS1 } from './bin/helper_scripts.nf'
include { GENERATE_SAMTOOLS_INDEX as GS2 } from './bin/helper_scripts.nf'
include { SKETCH_ALIGN            } from './bin/mashmap.nf'
include { MAKE_KARYOTYPE          } from './bin/circos.nf'
include { PREFIX_LINKS            } from './bin/circos.nf'
include { MAKE_CONF               } from './bin/circos.nf'
include { CIRCOS                  } from './bin/circos.nf'

workflow {
    ref_ch   = Channel.fromPath(params.ref_scaffolds,   checkIfExists: true)
    query_ch = Channel.fromPath(params.query_scaffolds, checkIfExists: true)

    fai_ref   = GS1(ref_ch).index
    fai_query = GS2(query_ch).index

    karyotype = MAKE_KARYOTYPE(fai_ref, fai_query).karyotype

    mashmap   = SKETCH_ALIGN(ref_ch, query_ch).mashmap_out
    links     = PREFIX_LINKS(mashmap).circos_links

    conf      = MAKE_CONF(karyotype)

    CIRCOS(conf, karyotype, links)
}
