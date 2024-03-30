#!/bin/bash

module=${1};
if [ -n "${module}" ] ; then 
    sed -i "s/^module/${module}/g" ${yonienv}/git_templates/git_commit_template_yonic;
fi

git config commit.template ${yonienv}/git_templates/git_commit_template_yonic; 
git commit;
git config --unset commit.template;
git checkout ${yonienv}/git_templates/git_commit_template_yonic;
