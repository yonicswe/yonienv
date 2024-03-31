#!/bin/bash

jira_ticket=${1};
module=${2:-nt};

if [[ $# -ne 2 ]] ; then
    echo "usage: $FUNCNAME <jira ticket> <module>"
    return -1;
fi;

if [ -n "${jira_ticket}" ] ; then 
    sed -i "s/\[MDT-.*\]/\[MDT-${jira_ticket}\]/g" ${yonienv}/git_templates/git_commit_dell_template;
fi

if [ -n "${module}" ] ; then 
    sed -i "s/cyc_module/${module}/g" ${yonienv}/git_templates/git_commit_dell_template;
fi

git config commit.template ${yonienv}/git_templates/git_commit_dell_template;
git commit -n;
git config --unset commit.template;
pushd ${yonienv} 2>/dev/null;
git checkout ${yonienv}/git_templates/git_commit_dell_template;
popd 2>/dev/null;
