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
#          BUGS: n/a
#         NOTES: Requires a valid API key from Google AI Studio.
#                The response behavior (prompt) can be adjusted within the script.
#        AUTHOR: ~marcelositr marcelositr@vaporhole.xyz (Adapted with AI help)
#  ORGANIZATION: vaporhole.xyz
#       CREATED: 05-26-2025
#       VERSION: 1.0
#      REVISION: n/a
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

# Capture the user's input
USER_INPUT="$*"
# Add instructions for the AI to be brief and direct (Prompt Engineering)
PROMPT_TEXT="Regras: Responda da forma mais curta e direta possível. Use apenas texto puro, sem nenhuma formatação como Markdown (negrito, listas, etc.). Pergunta do usuário: ${USER_INPUT}"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"
JSON_PAYLOAD=$(printf '{"contents":[{"parts":[{"text":"%s"}]}]}' "$PROMPT_TEXT")

echo -n "${MODEL_NAME} está pensando... " &
SPINNER_PID=$!
trap "kill $SPINNER_PID &>/dev/null; wait $SPINNER_PID &>/dev/null; echo -ne '\r\033[K'" EXIT

# Make the API call and store the response and the HTTP status code
HTTP_RESPONSE=$(curl -s -o /dev/stdout -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "${JSON_PAYLOAD}" \
  "${API_URL}")

# Extract the status code from the end of the response string
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)
# Remove the last line (the status code)
API_RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

kill $SPINNER_PID &>/dev/null
wait $SPINNER_PID &>/dev/null
echo -ne "\r\033[K"

# Check if the status code is not 200 (OK)
if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Erro: A API do Google retornou um erro (Código: $HTTP_STATUS)."
# Try to extract and display the error message from the JSON nicely
    ERROR_MESSAGE=$(echo "$API_RESPONSE_BODY" | jq -r '.error.message // "Não foi possível extrair a mensagem de erro detalhada."')
    echo "Detalhes: $ERROR_MESSAGE"
    exit 1
fi

# Extract the text from the successful response
RESPONSE_TEXT=$(echo "${API_RESPONSE_BODY}" | jq -r '.candidates[0].content.parts[0].text')

# This check is important in case the response is blocked for safety reasons, for example.
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

# Display the final response using the model name dynamically
echo -e "\n\033[30;42m${MODEL_NAME}:\033[0m\033[32m ${RESPONSE_TEXT}\033[0m\n"
