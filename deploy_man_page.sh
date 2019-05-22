#!/bin/bash

groff -man -Tascii ~/ipteam_env/ipteam_env_man_page > ~/ipteam_env/man/man8/ipteam_env.8
gzip -f ~/ipteam_env/man/man8/ipteam_env.8

groff -man -Tascii ~/ipteam_env/ipteam_aliases_man_page > ~/ipteam_env/man/man8/ipteam_aliases.8
gzip -f ~/ipteam_env/man/man8/ipteam_aliases.8

groff -man -Tascii ~/ipteam_env/ips_man_page > ~/ipteam_env/man/man8/ips.8
gzip -f ~/ipteam_env/man/man8/ips.8
