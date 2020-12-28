#!/bin/bash

alias editbashhabana='${v_or_g} ${yonienv}/bashrc_habana.sh'

create_habana_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3};
    user_pass=${4};
    alias ${alias_name}="sshpass -p ${user_pass} ssh -YX ${user_name}@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

create_habana_alias_for_host omer  oshpigelman-vm ycohen  yo1st21Hab
create_habana_alias_for_host k62 kvm-srv62-tlv labuser Hab12345
create_habana_alias_for_host k62u18a k62-u18-a  labuser Hab12345
create_habana_alias_for_host k62u18b k62-u18-b  labuser Hab12345
create_habana_alias_for_host k62u18c k62-u18-c  labuser Hab12345
create_habana_alias_for_host k62c75a k62-c75-a  labuser Hab12345
create_habana_alias_for_host k62c75b k62-c75-b  labuser Hab12345

create_habana_alias_for_host k61 kvm-srv61-tlv labuser Hab12345
create_habana_alias_for_host k61u18a k62-u18-a  labuser Hab12345
create_habana_alias_for_host k61u18b k62-u18-b  labuser Hab12345
create_habana_alias_for_host k61c k62-c75-a  labuser Hab12345
create_habana_alias_for_host k61c k62-c75-b  labuser Hab12345

create_habana_alias_for_host dali23 dali-srv23 labuser Hab12345

alias kmdsrv='~/kmd-srv.py'
alias kmdsrvfree='~/kmd-srv.py|grep -i free'
alias kmdsrvyoni='~/kmd-srv.py|grep -i ycohen'

gitcommithabana ()
{
    local jira_ticket=${1};
    if [ -n "${jira_ticket}" ] ; then 
        sed -i "s/\[SW-.*\]/\[SW-${jira_ticket}\]/g" ${yonienv}/git_templates/git_commit_habana_template;
    fi

    git config commit.template ${yonienv}/git_templates/git_commit_habana_template;
    git commit;
    git config --unset commit.template;
}
