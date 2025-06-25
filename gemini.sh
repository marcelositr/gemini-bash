#!/bin/bash
#===============================================================================
#
#          FILE: gemini.sh
#
#         USAGE: ./gemini.sh "Your question for the AI"
#
#   DESCRIPTION: Command-Line Interface (CLI) for the Google Gemini API.
#                Simplifies access to Google's AI directly from the terminal.
#
#       OPTIONS: n/a
#  REQUIREMENTS: bash, curl, jq, GEMINI_API_KEY environment variable
#          BUGS: The EXIT trap can clear the final output. Fixed in v1.3.
#         NOTES: Requires a valid API key from Google AI Studio.
#        AUTHOR: ~marcelositr marcelost@riseup.net
#       CREATED: 05-26-2025
#       VERSION: 1.1
#      REVISION: Fixed bug where the EXIT trap would erase the final output.
#===============================================================================

# --- CONFIGURATION ---
API_KEY="${GEMINI_API_KEY}"
# Model to be used. "gemini-1.5-flash-latest" is the best overall choice.
# gemini-1.5-flash-latest
# gemini-1.5-pro-latest
MODEL_NAME="gemini-1.5-flash-latest"

# --- INITIAL CHECKS ---
if [ -z "${API_KEY}" ]; then
  echo "Erro: A variável de ambiente GEMINI_API_KEY não está definida."
  exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "Erro: O comando 'jq' não foi encontrado. Por favor, instale-o."
    exit 1
fi
if [ "$#" -eq 0 ]; then
  echo "Uso: $0 \"<texto para a IA>\""
  exit 1
fi

# --- PREPARE AND EXECUTE THE REQUEST ---
USER_INPUT="$*"
PROMPT_TEXT="Instruções: Responda de forma tecnicamente precisa, mas que seja clara e de fácil entendimento. Limite sua resposta a no máximo 5 linhas. Use apenas texto puro, sem formatação Markdown (negrito, listas, etc.). Pergunta do usuário: ${USER_INPUT}"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"
JSON_PAYLOAD=$(printf '{"contents":[{"parts":[{"text":"%s"}]}]}' "$PROMPT_TEXT")

echo -n "${MODEL_NAME} está pensando... " &
SPINNER_PID=$!
trap "kill $SPINNER_PID &>/dev/null; wait $SPINNER_PID &>/dev/null; echo -ne '\r\033[K'" EXIT

HTTP_RESPONSE=$(curl -s -o /dev/stdout -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "${JSON_PAYLOAD}" \
  "${API_URL}")

HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)
API_RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

kill $SPINNER_PID &>/dev/null
wait $SPINNER_PID &>/dev/null
echo -ne "\r\033[K"

if [ "$HTTP_STATUS" -ne 200 ]; then
    if [[ "$HTTP_STATUS" -eq 429 ]] || \
       ([[ "$HTTP_STATUS" -eq 403 ]] && echo "$API_RESPONSE_BODY" | grep -q "rateLimitExceeded"); then
        echo -e "\n\033[31mErro: Limite de uso (quota) da API atingido. Tente novamente mais tarde.\033[0m\n"
    else
        echo -e "\n\033[31mErro: A API do Google retornou um erro inesperado (Código: $HTTP_STATUS).\033[0m"
        ERROR_MESSAGE=$(echo "$API_RESPONSE_BODY" | jq -r '.error.message // "Não foi possível extrair a mensagem de erro detalhada."')
        echo "Detalhes: $ERROR_MESSAGE"
    fi
    exit 1
fi

RESPONSE_TEXT=$(echo "${API_RESPONSE_BODY}" | jq -r '.candidates[0].content.parts[0].text')

if [ -z "$RESPONSE_TEXT" ] || [ "$RESPONSE_TEXT" == "null" ]; then
    BLOCK_REASON=$(echo "${API_RESPONSE_BODY}" | jq -r '.promptFeedback.blockReason // ""')
    if [ -n "$BLOCK_REASON" ]; then
        echo "Erro: A solicitação foi bloqueada pela API."
        FINISH_REASON=$(echo "${API_RESPONSE_BODY}" | jq -r '.candidates[0].finishReason // ""')
        echo "Motivo: ${BLOCK_REASON} (${FINISH_REASON})"
    else
        echo "Erro: Resposta recebida, mas o conteúdo está vazio ou nulo."
    fi
    exit 1
fi

# Disable the EXIT trap to prevent it from clearing the final output.
trap - EXIT

# Display the final response using the model name dynamically
echo -e "\n\033[30;42m${MODEL_NAME}:\033[0m\033[32m ${RESPONSE_TEXT}\033[0m\n"
