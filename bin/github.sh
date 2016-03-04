#!/usr/bin/env bash


# Clone all active repositories after system reinstallation.


repo_home=${HOME}/repo


repos=(
    unish.git # Will always be cloned manually
    emacs.d.git # Will always be cloned manually
    pat.git
    urlmark.git
    shellcoding.git
    pdfextract.git
    pdfmark.git
    lsext.git
    man2pdf.git
    simple-typing-game.git
    grade-management-system.git
)


mkdir -p "${repo_home}"


for one in ${repos[@]}; do
    if [[ -d "${repo_home}/${one}" ]]; then
        printf 'Already cloned: %s\n' ${one}
    else
        printf 'Cloning: %s\n' ${one}
        git clone "git@github.com:NoviceLive/${one}" \
            "${repo_home}/${one}"
    fi
done


unset repos one
