#!/usr/bin/env bash

if [ -d "$HOME/.ssh" ]; then
    chmod 400 "$HOME"/.ssh/{id_rsa_personal,id_rsa_work} &&
    eval "$(ssh-agent -s)" && ssh-add "$HOME"/.ssh/{id_rsa_personal,id_rsa_work}
fi
