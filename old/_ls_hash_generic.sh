# Preferred version:
_ls_hash_generic() {
    local alg="${1}"
    local dir="${2:-$PWD}"
    debug "$dir"
    find -maxdepth 1 -type f | while read -r filename; do
        $alg "${filename}"
    done | cut -d' ' -f1 | sort | tr '\n' ' '
    printf '\n'
}


# Original version:
_ls_hash_generic() {
    local alg="${1}"
    local dir="${2:-$PWD}"
    debug "$dir"
    for i in "$dir"/*; do
        if [[ -f "${i}" ]]; then
            $alg "${i}" | cut -d' ' -f1
        fi
    done | sort | tr '\n' ' '
    printf '\n'
}
