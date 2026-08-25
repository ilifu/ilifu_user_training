#!/usr/bin/env nextflow

// Session 4, Tutorial 1: Simple Nextflow Workflow
// Bioinformatics-inspired DNA sequence processing pipeline
//
// This workflow demonstrates:
// - Task definition with input/output
// - Connecting tasks via pipes
// - SLURM resource configuration
// - File publishing

// Define task 1: Trim sequences
process trim_reads {
    input:
        file fastq

    output:
        file "${fastq.baseName}.trimmed.fastq"

    script:
    """
    # Simulate trimming by taking first 80 characters of each sequence
    # In real work, you'd use cutadapt, trimmomatic, etc.
    awk '/^@/ {print; getline; print substr(\$0,1,80); getline; print; getline; print}' ${fastq} > ${fastq.baseName}.trimmed.fastq
    """
}

// Define task 2: Align sequences
process align_sequences {
    input:
        file trimmed_fastq

    output:
        file "${trimmed_fastq.baseName}.sam"

    script:
    """
    # Simulate alignment by adding header and marking all as mapped
    # In real work, you'd use bwa, bowtie2, etc.
    (echo "@HD	VN:1.0	SO:coordinate"; \
     awk 'NR % 4 == 2' ${trimmed_fastq} | head -100 | awk '{print NR "\t0\tref\t" NR "\t60\t" length(\$0) "M\t*\t0\t0\t" \$0 "\tIIIIII"}') > ${trimmed_fastq.baseName}.sam
    """
}

// Define task 3: Count hits
process count_alignments {
    publishDir "results", mode: 'copy'

    input:
        file sam_file

    output:
        file "${sam_file.baseName}.counts.txt"

    script:
    """
    TOTAL=\$(grep -v '@' ${sam_file} | wc -l)
    echo "Total alignments: \$TOTAL" > ${sam_file.baseName}.counts.txt
    echo "Alignment rate: 100%" >> ${sam_file.baseName}.counts.txt
    """
}

// Define the main workflow
workflow {
    // Create input channel from FASTQ files in data/ directory
    fastq_files = Channel.fromPath('data/*.fastq')

    // Connect tasks using pipes (|)
    // Output of one task becomes input to the next
    trim_reads(fastq_files) | align_sequences | count_alignments
}
