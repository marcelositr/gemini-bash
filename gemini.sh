#!/bin/bash
#===============================================================================
#
#          FILE: gemini.sh
#
#         USAGE: ./gemini.sh "Your question for the AI"
#
#   DESCRIPTION: Command-Line Interface (CLI) for the Google Gemini API.
#                Simplifies access to Google's AI directly from the terminal.
#                Refactored based on Clean Code principles.
#
#       OPTIONS: n/a
#  REQUIREMENTS: bash, curl, jq, GEMINI_API_KEY environment variable
#          BUGS: n/a
#         NOTES: Requires a valid API key from Google AI Studio.
#        AUTHOR: ~marcelositr marcelost@riseup.net (Refactored by AI)
#       CREATED: 05-26-2025
#       VERSION: 2.1
#      REVISION: Fixed shellcheck SC2064 warning by deferring variable expansion in trap.
#
#===============================================================================

# --- CONFIGURATION (Constants) ---
readonly API_KEY="${GEMINI_API_KEY}"
readonly MODEL_NAME="gemini-1.5-flash-latest" # gemini-1.5-pro-latest
readonly API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"

# --- FUNCTIONS ---

function die() {
    echo -e "\n\033[31mErro: $1\033[0m" >&2
    exit 1
}

function validate_prerequisites() {
    if [[ -z "${API_KEY}" ]]; then
        die "A variável de ambiente GEMINI_API_KEY não está definida."
    fi
    if ! command -v jq &>/dev/null; then
        die "O comando 'jq' não foi encontrado. Por favor, instale-o."
    fi
    if [[ "$#" -eq 0 ]]; then
        die "Uso: $0 \"<texto para a IA>\""
    fi
}

function build_json_payload() {
    local user_input="$1"
    local prompt_instructions="Instruções: Responda de forma tecnicamente precisa, mas que seja clara e de fácil entendimento. Limite sua resposta a no máximo 5 linhas. Use apenas texto puro, sem formatação Markdown (negrito, listas, etc.)."
    local final_prompt="Pergunta do usuário: ${user_input}"

    printf '{"contents":[{"parts":[{"text":"%s %s"}]}]}' "$prompt_instructions" "$final_prompt"
}

function handle_api_error() {
    local http_status="$1"
    local response_body="$2"

    if [[ "$http_status" -eq 429 ]] || \
       ( [[ "$http_status" -eq 403 ]] && echo "$response_body" | grep -q "rateLimitExceeded" ); then
        die "Limite de uso (quota) da API atingido. Tente novamente mais tarde."
    else
        local error_message
        error_message=$(echo "$response_body" | jq -r '.error.message // "Não foi possível extrair a mensagem de erro detalhada."')
        die "A API do Google retornou um erro inesperado (Código: ${http_status}).\nDetalhes: ${error_message}"
    fi
}

function parse_success_response() {
    local response_body="$1"
    local response_text

    response_text=$(echo "${response_body}" | jq -r '.candidates[0].content.parts[0].text')

    if [[ -z "$response_text" || "$response_text" == "null" ]]; then
        local block_reason
        block_reason=$(echo "${response_body}" | jq -r '.promptFeedback.blockReason // ""')
        
        if [[ -n "$block_reason" ]]; then
            local finish_reason
            finish_reason=$(echo "${response_body}" | jq -r '.candidates[0].finishReason // ""')
            die "A solicitação foi bloqueada pela API. Motivo: ${block_reason} (${finish_reason})"
        else
            die "Resposta recebida, mas o conteúdo está vazio ou nulo."
        fi
    fi
    echo "$response_text"
}


# --- MAIN EXECUTION ---

function main() {
    validate_prerequisites "$@"

    local user_input="$*"
    local json_payload
    json_payload=$(build_json_payload "$user_input")

    echo -n "${MODEL_NAME} está pensando... " &
    local spinner_pid=$!
    
    # CORREÇÃO APLICADA AQUI: O $ de spinner_pid foi escapado com \
    # Isso adia a expansão da variável para o momento em que o trap é executado,
    # satisfazendo o shellcheck (SC2064) sem quebrar o echo.
    trap "kill \$spinner_pid &>/dev/null; wait \$spinner_pid &>/dev/null; echo -ne '\r\033[K'" EXIT

    local curl_output
    curl_output=$(curl -s -o /dev/stdout -w "\n%{http_code}" \
      -H "Content-Type: application/json" \
      -d "${json_payload}" \
      "${API_URL}")

    kill $spinner_pid &>/dev/null
    wait $spinner_pid &>/dev/null
    echo -ne "\r\033[K"

    local http_status
    local api_response_body
    http_status=$(echo "$curl_output" | tail -n1)
    api_response_body=$(echo "$curl_output" | sed '$d')

    if [[ "$http_status" -ne 200 ]]; then
        handle_api_error "$http_status" "$api_response_body"
    fi

    local final_text
    final_text=$(parse_success_response "$api_response_body")

    trap - EXIT

    echo -e "\n\033[30;42m ${MODEL_NAME} \033[0m\033[32m ${final_text}\033[0m\n"
}

# The script's entry point.
main "$@"
