default:
    @just --list --unsorted

config := absolute_path('config')
build := absolute_path('.build')
out := absolute_path('firmware')
draw := absolute_path('draw')


# parse combos.dtsi and adjust settings to not run out of slots
_parse_combos $dconf:
    #!/usr/bin/env bash
    set -euo pipefail
    cconf="{{ config / 'combos.dtsi' }}"
    if [[ -f $cconf ]]; then
        # set MAX_COMBOS_PER_KEY to the most frequent combos count
        count=$(
            tail -n +10 $cconf |
                grep -Eo '[LR][TMBH][0-9]' |
                sort | uniq -c | sort -nr |
                awk 'NR==1{print $1}'
        )
        sed -Ei "/CONFIG_ZMK_COMBO_MAX_COMBOS_PER_KEY/s/=.+/=$count/" "{{ '$dconf' }}"/*.conf
        echo "Setting MAX_COMBOS_PER_KEY to $count"

        # set MAX_KEYS_PER_COMBO to the most frequent key count
        count=$(
            tail -n +10 $cconf |
                grep -o -n '[LR][TMBH][0-9]' |
                cut -d : -f 1 | uniq -c | sort -nr |
                awk 'NR==1{print $1}'
        )
        sed -Ei "/CONFIG_ZMK_COMBO_MAX_KEYS_PER_COMBO/s/=.+/=$count/" "{{ '$dconf' }}"/*.conf
        echo "Setting MAX_KEYS_PER_COMBO to $count"
    fi

# parse build.yaml and filter targets by expression
_parse_targets $expr:
    #!/usr/bin/env bash
    attrs="[.board, .shield, .dconf]"
    filter="(($attrs | map(. // [.]) | combinations), ((.include // {})[] | $attrs)) | join(\",\")"
    echo "$(yq -r "$filter" build.yaml | grep -v "^," | grep -i "${expr/#all/.*}")"

# build firmware for single board & shield combination
_build_single $board $shield $dconf *west_args:
    #!/usr/bin/env bash
    set -euo pipefail
    artifact="${shield:+${shield// /+}-}${board}"
    build_dir="{{ build / '$artifact' }}"

    echo "Building firmware for $artifact with config $dconf"
    west build -s zmk/app -d "$build_dir" -b $board {{ west_args }} -- \
        -DZMK_CONFIG="{{ '$dconf' }}" ${shield:+-DSHIELD="$shield"}

    if [[ -f "$build_dir/zephyr/zmk.uf2" ]]; then
        mkdir -p "{{ out }}" && cp "$build_dir/zephyr/zmk.uf2" "{{ out }}/$artifact.uf2"
    else
        mkdir -p "{{ out }}" && cp "$build_dir/zephyr/zmk.bin" "{{ out }}/$artifact.bin"
    fi

# build firmware for matching targets
build expr *west_args:
    #!/usr/bin/env bash
    set -euo pipefail
    targets=$(just _parse_targets {{ expr }})

    [[ -z $targets ]] && echo "No matching targets found. Aborting..." >&2 && exit 1
    echo "$targets" | while IFS=, read -r board shield dconf; do
        just _parse_combos "$dconf"
        just _build_single "$board" "$shield" "$dconf" {{ west_args }}
    done

# clear build cache and artifacts
clean:
    rm -rf {{ build }} {{ out }}

# clear all automatically generated files
clean-all: clean
    rm -rf .west zmk

# clear nix cache
clean-nix:
    nix-collect-garbage --delete-old

# parse & plot keymap
draw:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Drawing corne keymap"
    keymap -c "{{ draw }}/config.yaml" parse -z "{{ config }}/corne_mx/corne.keymap" >"{{ draw }}/corne.yaml"
    keymap -c "{{ draw }}/config.yaml" draw "{{ draw }}/corne.yaml" -k "splitkb/aurora/corne/rev1" >"{{ draw }}/corne.svg"

    echo "Drawing sofle keymap"
    keymap -c "{{ draw }}/config.yaml" parse -z "{{ config }}/sofle.keymap" >"{{ draw }}/sofle.yaml"
    keymap -c "{{ draw }}/config.yaml" draw "{{ draw }}/sofle.yaml" -k "splitkb/aurora/sofle_v2/rev1" >"{{ draw }}/sofle.svg"

    echo "Drawing lily58 keymap"
    keymap -c "{{ draw }}/config.yaml" parse -z "{{ config }}/lily58.keymap" >"{{ draw }}/lily58.yaml"
    keymap -c "{{ draw }}/config.yaml" draw "{{ draw }}/lily58.yaml" -k "splitkb/aurora/lily58/rev1" >"{{ draw }}/lily58.svg"

# initialize west
init:
    west init -l config
    west update
    west zephyr-export

# list build targets
list:
    @just _parse_targets all | sed 's/,$//' | sort | column

# update west
update:
    west update

# upgrade zephyr-sdk and python dependencies
upgrade-sdk:
    nix flake update --flake .

run:
    @just build all
    @just draw
