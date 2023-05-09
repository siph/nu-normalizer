#!/usr/bin/env nu

use std

let EXTENSIONS = [ mp4 mkv mov ]

let SAMPLE_RATE = 48k

# Ceiling values for output.
let CEILING = {
    OUT_I: -16          # Integrated
    OUT_TP: -1.5        # True Peak
    OUT_LRA: 11         # Loudness Range
    OUT_OFFSET: -0.7    # Offset
}

# Normalizes audio using `loudnorm` with `ffmpeg`
def main [
    --directory (-d): string,   # Directory of files to be normalized
    --recursive (-r),           # Normalize files recursively
] {
    let output = $"($directory)/normalized"
    mkdir $output
    let files = (
        (
            if $recursive {
                ls $"($directory)/**/*"
            } else { ls $directory }
        )
        | path parse -c [ name ]
        | where { |it| $it.type == file }
        | where { |it| ($it.name.parent | str contains $"($directory)/normalized") != true }
        | where { |it| $EXTENSIONS | any { |ex| $it.name.extension == $ex } }
    )
    $files | each { |it|
        let file = ($it.name | path join | path expand)
        normalize $file $output
    }
}

# Get first-pass loudnorm values
def get_measured [
    target: string  # File to evaluate
] {
    std log debug $"Measuring values on file: ($target)"
    let measured = (
        run-external --redirect-stderr "ffmpeg" "-i" $"`($target)`" "-filter:a" "loudnorm=print_format=json" "-f" "null" "NULL"
        | complete
        | $in.stderr
        | str substring ($in | str index-of '{')..(($in | str index-of '}') + 1)
        | from json)
    return $measured
}

# Normalize target
def normalize [
    target: string, # File to evaluate
    output: string, # Output directory
] {
    std log info $"Normalizing audio on file: ($target)"
    std log info $"Saving file to directory: ($output)"
    let measured = (get_measured $target)
    let parsed = ($target | path parse)
    run-external "ffmpeg" "-i" $"'($target)'" "-filter:a" $"loudnorm=linear=true:i=($CEILING.OUT_I):lra=($CEILING.OUT_LRA):tp=($CEILING.OUT_TP):offset=($CEILING.OUT_OFFSET):measured_I=($measured.input_i):measured_tp=($measured.input_tp):measured_LRA=($measured.input_lra):measured_thresh=($measured.input_thresh)" "-ar" "48000" "-c:a" "aac" "-b:a" $"($SAMPLE_RATE)" $"'($output)/($parsed.stem).($parsed.extension)'"
}
