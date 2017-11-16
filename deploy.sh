#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/
#/ Usage:
#/    ./deploy.sh [action]
#/ Description:
#/    Deploy your Lambda function payloads to AWS.
#/ Examples:
#/    ./deploy.sh plan
#/    ./deploy.sh apply
#/ Actions:
#/    plan    - Test terraform configuration
#/    apply   - Apply terraform configuration
#/    destroy - Destroy all resources created in terraform
#/ Options:
#/    --help: Display this help message
#/
#/

usage() { grep '^#/' "${0}" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "${0}").log"
info()    { echo "[INFO]    $*" | tee -a "${LOG_FILE}" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "${LOG_FILE}" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "${LOG_FILE}" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "${LOG_FILE}" >&2 ; exit 1 ; }

terraform_init() {
    info "Running terraform init"
    terraform init || fatal "Could not initialize terraform"
}

terraform_plan() {
    info "Running terraform plan"
    terraform plan || error "Terraform plan failed"
}

terraform_apply() {
    info "Running terraform init"
    terraform apply || error "Terraform apply failed"
}

terraform_destroy() {
    info "Running terraform destroy"
    terraform destroy || error "Terraform destroy failed"
}

setup() {
    if [[ ! -d ".terraform" ]] ; then
        terraform_init
    fi
}

build_payloads() {
    info "Building payload files."
    local __PWD=$(pwd)
    cd payloads
    for file in * ; do
        local script="${file%.*}"
        info "Adding ${file} to .lambda_${script}_payload.zip"
        zip -r9 "../.lambda_${script}_payload.zip" "${file}" || \
            fatal "Could not build payload files"
    done
    cd "${__PWD}"
}

cleanup() {
    info "Cleaning up temporary payload files."
    for zipfile in $(find . -type f -name ".lambda_*_payload.zip") ; do
        test -f "${zipfile}" && info "Removing ${zipfile}"
        test -f "${zipfile}" && rm "${zipfile}"
    done
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    trap cleanup EXIT
    if [[ ${#} -gt 0 ]] ; then
        case "${1}" in
            "plan")
                build_payloads
                terraform_plan
                ;;
            "apply")
                build_payloads
                terraform_apply
                ;;
            "destroy")
                build_payloads
                terraform_destroy
                ;;
            "help")
                usage
                ;;
            *)
                fatal "Unknown command: ${1} $(usage)"
                ;;
        esac
    else
        fatal "No command supplied $(usage)"
    fi
fi
