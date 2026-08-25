version 1.0

# Session 4, Tutorial 1: WDL Workflow Example
# Astronomy-inspired image reduction pipeline
#
# This workflow demonstrates:
# - Task definitions with explicit typing
# - Scatter-gather parallelization pattern
# - Resource allocation for tasks
# - Array operations and string functions

task bias_correction {
    input {
        File raw_image
    }

    output {
        File corrected_image = "${basename(raw_image, '.fits')}_bias_corrected.fits"
    }

    command {
        # Simulate bias correction (subtract a constant)
        # In real work, you'd use FITS libraries and subtract master bias frames
        python3 << 'PYTHON_SCRIPT'
        import sys

        # Read mock image data (pixel values, one per line)
        with open("${raw_image}", "r") as f:
            lines = f.readlines()

        # Simulate bias subtraction
        corrected = [f"{int(line.strip()) - 100}\n" for line in lines if line.strip().isdigit()]

        # Write corrected image
        with open("${basename(raw_image, '.fits')}_bias_corrected.fits", "w") as f:
            f.writelines(corrected)

        print("Bias correction complete")
        PYTHON_SCRIPT
    }

    runtime {
        # Can optionally specify Docker container for reproducibility
        # docker: "python:3.10"
        cpu: 1
        memory: "1 GB"
        disks: "10 GB"
    }
}

task flat_field_correction {
    input {
        File bias_corrected_image
    }

    output {
        File flat_corrected_image = "${basename(bias_corrected_image, '.fits')}_flat_corrected.fits"
    }

    command {
        python3 << 'PYTHON_SCRIPT'
        import sys

        # Read bias-corrected image
        with open("${bias_corrected_image}", "r") as f:
            values = [int(line.strip()) for line in f if line.strip().isdigit()]

        # Simulate flat-field correction (normalize by average)
        avg = sum(values) / len(values) if values else 1
        corrected = [f"{int(v / (avg / 100))}\n" for v in values]

        # Write corrected image
        with open("${basename(bias_corrected_image, '.fits')}_flat_corrected.fits", "w") as f:
            f.writelines(corrected)

        print("Flat-field correction complete")
        PYTHON_SCRIPT
    }

    runtime {
        cpu: 1
        memory: "1 GB"
    }
}

task stack_images {
    input {
        Array[File] flat_corrected_images
    }

    output {
        File stacked_image = "stacked_image.fits"
    }

    command {
        # Simulate image stacking by concatenating files
        cat ${sep=' ' flat_corrected_images} > stacked_image.fits
        echo "Stacking complete: combined ${length(flat_corrected_images)} images"
    }

    runtime {
        cpu: 2
        memory: "4 GB"
    }
}

workflow image_reduction {
    input {
        Array[File] raw_images
    }

    # Scatter: apply bias correction to all images in parallel
    scatter (image in raw_images) {
        call bias_correction { input: raw_image = image }
    }

    # Scatter: apply flat-field correction to all bias-corrected images
    scatter (bias_corrected in bias_correction.corrected_image) {
        call flat_field_correction { input: bias_corrected_image = bias_corrected }
    }

    # Gather: collect all flat-corrected images and stack them
    call stack_images { input: flat_corrected_images = flat_field_correction.flat_corrected_image }

    output {
        File final_image = stack_images.stacked_image
        Array[File] corrected_images = flat_field_correction.flat_corrected_image
    }
}
