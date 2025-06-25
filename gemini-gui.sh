#!/bin/bash
#===============================================================================
#
#          FILE: gemini-gui.sh
#
#         USAGE: ./gemini-gui.sh
#
#   DESCRIPTION: Minimalist Graphical User Interface (GUI) for the Google Gemini API.
#                Provides a simple Zenity-based GUI to interact with Google's AI.
#
#       OPTIONS: n/a
#  REQUIREMENTS: bash, curl, jq, zenity, GEMINI_API_KEY environment variable
#          BUGS: n/a
#         NOTES: Requires a valid API key from Google AI Studio.
#                The response behavior (prompt) can be adjusted within the script.
#        AUTHOR: ~marcelositr marcelost@riseup.net
#       CREATED: 25-06-2025
#       VERSION: 1.0
#      REVISION: 
#===============================================================================

# --- CONFIGURATION ---
API_KEY="${GEMINI_API_KEY}"
# Model to be used. "gemini-1.5-flash-latest" is the best overall choice.
# gemini-1.5-flash-latest
# gemini-1.5-pro-latest
MODEL_NAME="gemini-1.5-flash-latest"

# --- FUNCTION FOR ERROR DIALOG ---
# Displays an error dialog without exiting the script, allowing the user to try again.
show_error() {
    zenity --error --width=400 --title="Erro" --text="$1"
}

# --- INITIAL CHECKS ---
# Perform dependency checks once at startup.
if [ -z "${API_KEY}" ]; then
  zenity --error --width=400 --title="Erro" --text="A variável de ambiente GEMINI_API_KEY não está definida."
  exit 1
fi
for cmd in jq zenity curl; do
    if ! command -v $cmd &> /dev/null; then
        zenity --error --width=400 --title="Erro" --text="O comando '$cmd' não foi encontrado. Por favor, instale-o."
        exit 1
    fi
done

# --- MAIN LOOP ---
while true; do

    # --- WINDOW 1: GET USER INPUT ---
    USER_INPUT=$(zenity --entry \
      --title="Pergunta para o Gemini" \
      --text="Digite sua pergunta para a IA:" \
      --width=500)

    # If the user clicks 'Cancel' or closes the dialog, exit the loop.
    if [ $? -ne 0 ]; then
        break
    fi

    # --- PREPARE AND EXECUTE THE API REQUEST ---
    PROMPT_TEXT="Instruções: Responda de forma tecnicamente precisa, mas que seja clara e de fácil entendimento. Limite sua resposta a no máximo 5 linhas. Use apenas texto puro, sem formatação Markdown (negrito, listas, etc.). Pergunta do usuário: ${USER_INPUT}"
    API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"
    JSON_PAYLOAD=$(printf '{"contents":[{"parts":[{"text":"%s"}]}]}' "$PROMPT_TEXT")

    # Display a progress bar while waiting for the API response.
    ( echo "# Consultando a IA ${MODEL_NAME}..."; sleep 20 ) | zenity --progress \
      --title="Aguarde" --pulsate --auto-close --no-cancel --width=300 &
    PROGRESS_PID=$!

    # Make the API call.
    API_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
      -H "Content-Type: application/json" \
      -d "${JSON_PAYLOAD}" \
      "${API_URL}")

    # Kill the progress bar as soon as curl finishes.
    kill $PROGRESS_PID &>/dev/null

    # Separate the response body from the HTTP status code.
    HTTP_STATUS=$(echo "$API_RESPONSE" | tail -n1 | cut -d: -f2)
    API_RESPONSE_BODY=$(echo "$API_RESPONSE" | sed '$d')

    # --- PROCESS THE RESPONSE ---
    if [ "$HTTP_STATUS" -ne 200 ]; then
        ERROR_MESSAGE=$(echo "$API_RESPONSE_BODY" | jq -r '.error.message // "Unknown error."')
        show_error "A API retornou um erro (Código: $HTTP_STATUS).\n\nDetalhes: $ERROR_MESSAGE"
        # On error, show a message and continue to the next loop iteration.
        continue
    fi

    RESPONSE_TEXT=$(echo "${API_RESPONSE_BODY}" | jq -r '.candidates[0].content.parts[0].text')

    if [ -z "$RESPONSE_TEXT" ] || [ "$RESPONSE_TEXT" == "null" ]; then
        show_error "A resposta da API veio vazia ou foi bloqueada."
        # If the response is empty or blocked, show an error and continue.
        continue
    fi

    # --- WINDOW 2: DISPLAY RESPONSE AND ASK FOR NEXT ACTION ---
    # Use a single `zenity --question` dialog to both display the result
    # and prompt for the next action.
    zenity --question \
      --title="Resposta do ${MODEL_NAME}" \
      --width=600 \
      --text="<b>Resposta para:</b>\n<i>${USER_INPUT}</i>\n\n---\n${RESPONSE_TEXT}" \
      --ok-label="Nova Pergunta" \
      --cancel-label="Sair"

    # `zenity --question` returns 0 for the OK label ("Nova Pergunta") and 1 for
    # the Cancel label ("Sair"). If the user chooses to exit (exit code 1), break the loop.
    if [ $? -ne 0 ]; then
        break
    fi

done

echo "Script finished."
exit 0