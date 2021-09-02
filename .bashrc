set -o vi

for f in ./.config/bash_config/*; do source "$f"; done

eval "$(starship init bash)"
