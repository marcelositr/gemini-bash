#!/bin/bash
#===============================================================================
#
#          FILE: gemini.sh
#
#         USAGE: ./gemini.sh "Sua pergunta para a IA"
#
#   DESCRIPTION: Interface de Linha de Comando (CLI) para a API do Google Gemini.
#                Simplifica o acesso à IA do Google diretamente do terminal.
#
#       OPTIONS: n/a
#  REQUIREMENTS: bash, curl, jq, Variável de ambiente GEMINI_API_KEY
#          BUGS: n/a
#         NOTES: Requer uma chave de API válida do Google AI Studio.
#                O comportamento da resposta (prompt) pode ser ajustado no script.
#        AUTHOR: ~marcelositr marcelost@riseup.net
#       CREATED: 23/05/2024
#       VERSION: 1.0
#      REVISION: n/a
#===============================================================================

# --- CONFIGURAÇÃO ---
API_KEY="${GEMINI_API_KEY}"
# Nome do modelo a ser usado. "gemini-1.5-flash-latest" é a melhor escolha geral.
# gemini-1.5-flash-latest - Mais eficiente bom baixo consumo de cotas, ideal para contas gratuítas
# gemini-1.5-pro-latest - Mais poderso e consomem mais cotas
MODEL_NAME="gemini-1.5-flash-latest"

# --- VERIFICAÇÕES INICIAIS ---
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

# --- PREPARAÇÃO E EXECUÇÃO DA REQUISIÇÃO ---
USER_INPUT="$*"
PROMPT_TEXT="Regras: Responda da forma mais curta e direta possível. Use apenas texto puro, sem nenhuma formatação como Markdown (negrito, listas, etc.). Pergunta do usuário: ${USER_INPUT}"
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
    echo "Erro: A API do Google retornou um erro (Código: $HTTP_STATUS)."
    ERROR_MESSAGE=$(echo "$API_RESPONSE_BODY" | jq -r '.error.message // "Não foi possível extrair a mensagem de erro detalhada."')
    echo "Detalhes: $ERROR_MESSAGE"
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

# Exibe a resposta final usando o nome do modelo de forma dinâmica
echo -e "\n\033[30;42m${MODEL_NAME}:\033[0m\033[32m ${RESPONSE_TEXT}\033[0m\n"
