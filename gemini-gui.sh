#!/bin/bash
#===============================================================================
#
#          FILE: gemini-gui-final.sh
#
#         USAGE: ./gemini-gui-final.sh
#
#   DESCRIPTION: A minimalist GUI for the Google Gemini API using Zenity.
#                Operates in a loop for sequential queries.
#
#       OPTIONS: n/a
#  REQUIREMENTS: bash (v4+), curl, jq, zenity, GEMINI_API_KEY environment variable.
#          BUGS: n/a
#         NOTES: Fully compliant with shellcheck.
#        AUTHOR: ~marcelositr marcelost@riseup.net
#       CREATED: 25-06-2025
#       VERSION: 2.0
#      REVISION: Final refactoring to fix all shellcheck warnings (SC2181, SC2064)
#                and improve overall robustness and code clarity.
#
#===============================================================================

# --- CONFIGURATION (Constants) ---
readonly API_KEY="${GEMINI_API_KEY}"
readonly MODEL_NAME="gemini-1.5-flash-latest"
readonly SYSTEM_PROMPT="Instruções: Responda de forma tecnicamente precisa, mas que seja clara e de fácil entendimento. Limite sua resposta a no máximo 5 linhas. Use apenas texto puro, sem formatação Markdown (negrito, listas, etc.)."

# --- CORE FUNCTIONS ---

# Main entry point. Orchestrates the application loop and startup checks.
main() {
    check_dependencies

    while true; do
        local user_input
        # Correctly check command exit code directly (Fixes SC2181)
        if ! user_input=$(get_user_input); then
            break # Exit loop if user cancels
        fi

        local api_response
        api_response=$(call_gemini_api "$user_input")

        local response_text
        # Check the exit code of the processing function directly.
        if ! response_text=$(process_api_response "$api_response"); then
            continue # Skip to the next loop iteration on any processing error
        fi

        # Correctly check command exit code directly (Fixes SC2181)
        if ! display_result "$user_input" "$response_text"; then
            break # Exit loop if user chooses to quit
        fi
    done

    echo "Script finalizado."
}

# Verifies that all required dependencies are available.
check_dependencies() {
    if [[ -z "${API_KEY}" ]]; then
      show_error "A variável de ambiente GEMINI_API_KEY não está definida." "Erro de Configuração"
      exit 1
    fi
    for cmd in jq zenity curl; do
        if ! command -v "$cmd" &>/dev/null; then
            show_error "O comando '$cmd' não foi encontrado. Por favor, instale-o." "Erro de Dependência"
            exit 1
        fi
    done
}

# --- UI AND INTERACTION FUNCTIONS ---

# Displays a dialog to get the user's question.
get_user_input() {
    zenity --entry \
      --title="Pergunta para o Gemini" \
      --text="Digite sua pergunta para a IA:" \
      --width=500
}

# Displays the final response and asks for the next action.
display_result() {
    local user_input="$1"
    local response_text="$2"

    zenity --question \
      --title="Resposta do ${MODEL_NAME}" \
      --width=600 \
      --text="<b>Sua pergunta:</b>\n<i>${user_input}</i>\n\n---\n${response_text}" \
      --ok-label="Nova Pergunta" \
      --cancel-label="Sair"
}

# Displays a generic error dialog.
# Arguments: $1 - Error message. $2 - (Optional) Window title.
show_error() {
    local message="$1"
    local title="${2:-Ocorreu um Erro}" # Use a default title if not provided
    zenity --error --width=450 --title="$title" --text="$message"
}

# --- API HANDLING FUNCTIONS ---

# Calls the Gemini API and manages the progress dialog.
call_gemini_api() {
    local user_input="$1"
    local final_prompt="Pergunta do usuário: ${user_input}"
    local api_url="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"
    local json_payload
    json_payload=$(printf '{"contents":[{"parts":[{"text":"%s %s"}]}]}' "$SYSTEM_PROMPT" "$final_prompt")

    # Start the progress dialog in the background.
    zenity --progress --title="Aguarde" --text="Consultando a IA ${MODEL_NAME}..." \
      --pulsate --auto-close --no-cancel --width=300 &
    local progress_pid=$!

    # **CORREÇÃO DEFINITIVA (SC2064):**
    # Use aspas simples para adiar a expansão de ${progress_pid}.
    # O trap agora fecha a janela de progresso em QUALQUER saída (normal ou erro/Ctrl+C).
    trap 'kill ${progress_pid} &>/dev/null' EXIT

    local api_response
    api_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
      -H "Content-Type: application/json" \
      -d "${json_payload}" \
      "${api_url}")

    # O trap cuidará de matar o processo, mas fazemos isso aqui explicitamente
    # para garantir que a janela feche IMEDIATAMENTE após o curl, e não no fim
    # do script. O trap serve como uma garantia para saídas inesperadas.
    kill "${progress_pid}" &>/dev/null

    # Desarma o trap, pois a operação crítica (curl) terminou com sucesso.
    # Isso evita que ele feche outras janelas do zenity se elas aparecerem mais tarde.
    trap - EXIT

    echo "$api_response"
}

# Parses the raw API response, handles errors, and extracts the clean text.
process_api_response() {
    local api_response="$1"
    local http_status
    http_status=$(echo "$api_response" | tail -n1 | cut -d: -f2)
    local api_response_body
    api_response_body=$(echo "$api_response" | sed '$d')

    if [[ "$http_status" -ne 200 ]]; then
        local error_message
        error_message=$(echo "$api_response_body" | jq -r '.error.message // "Erro desconhecido."')
        show_error "A API retornou um erro (Código: $http_status).\n\n<b>Detalhes:</b> $error_message"
        return 1
    fi

    local response_text
    response_text=$(echo "${api_response_body}" | jq -r '.candidates[0].content.parts[0].text')

    if [[ -z "$response_text" || "$response_text" == "null" ]]; then
        show_error "A resposta da API veio vazia ou foi bloqueada por políticas de segurança."
        return 1
    fi

    echo "$response_text"
    return 0
}

# --- SCRIPT EXECUTION ---
main
