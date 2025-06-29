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
#       VERSION: 0.1
#      REVISION: Final refactoring to fix all shellcheck warnings (SC2181, SC2064)
#                and improve overall robustness and code clarity.
#
#===============================================================================

# --- CONFIGURATION (Constants) ---
readonly API_KEY="${GEMINI_API_KEY}"
readonly MODEL_NAME="gemini-1.5-flash-latest"
readonly SYSTEM_PROMPT="Instruções: Responda de forma tecnicamente precisa, mas que seja clara e de fácil entendimento. Limite sua resposta a no máximo 5 linhas. Use apenas texto puro, sem formatação Markdown (negrito, listas, etc.)."

# --- CORE FUNCTIONS ---

# Main function: Orchestrates the application loop and startup checks.
main() {
    # Perform initial checks for dependencies and configuration.
    check_dependencies

    # Enter the main loop for continuous interaction.
    while true; do
        local user_input
        # Get input from the user. If the user cancels, the function returns a non-zero exit code.
        if ! user_input=$(get_user_input); then
            break # Exit the loop if the user cancels the input dialog.
        fi

        local api_response
        # Call the Gemini API with the user's input.
        api_response=$(call_gemini_api "$user_input")

        local response_text
        # Process the raw API response. If processing fails, show an error and restart the loop.
        if ! response_text=$(process_api_response "$api_response"); then
            continue # Skip to the next loop iteration on any processing error.
        fi

        # Display the final result. If the user chooses to quit, the function returns a non-zero exit code.
        if ! display_result "$user_input" "$response_text"; then
            break # Exit the loop if the user chooses to quit in the result dialog.
        fi
    done

    # A final message indicating the script has terminated gracefully.
    echo "Script finished."
}

# Verifies that all required dependencies are available and the API key is set.
check_dependencies() {
    # Check if the GEMINI_API_KEY environment variable is set.
    if [[ -z "${API_KEY}" ]]; then
      show_error "The environment variable GEMINI_API_KEY is not set." "Configuration Error"
      exit 1
    fi
    # Loop through a list of required command-line tools.
    for cmd in jq zenity curl; do
        # Use 'command -v' to check if the command exists in the system's PATH.
        if ! command -v "$cmd" &>/dev/null; then
            show_error "The command '$cmd' was not found. Please install it." "Dependency Error"
            exit 1
        fi
    done
}

# --- UI AND INTERACTION FUNCTIONS ---

# Displays a dialog to get the user's question.
# Returns the user's text on success or a non-zero exit code on cancellation.
get_user_input() {
    zenity --entry \
      --title="Question for Gemini" \
      --text="Enter your question for the AI:" \
      --width=500
}

# Displays the AI's response and asks for the next action.
# Arguments:
#   $1: The original user question (user_input).
#   $2: The formatted AI response (response_text).
# Returns 0 if "New Question" is clicked, 1 if "Quit" is clicked.
display_result() {
    local user_input="$1"
    local response_text="$2"

    zenity --question \
      --title="Response from ${MODEL_NAME}" \
      --width=600 \
      --text="<b>Your question:</b>\n<i>${user_input}</i>\n\n---\n${response_text}" \
      --ok-label="New Question" \
      --cancel-label="Quit"
}

# Displays a generic error dialog.
# Arguments:
#   $1: The error message to display.
#   $2: (Optional) The window title. Defaults to "An Error Occurred".
show_error() {
    local message="$1"
    # Use parameter expansion to set a default title if the second argument is not provided.
    local title="${2:-An Error Occurred}"
    zenity --error --width=450 --title="$title" --text="$message"
}

# --- API HANDLING FUNCTIONS ---

# Calls the Gemini API, manages a progress dialog, and returns the raw response.
# Arguments:
#   $1: The user's question (user_input).
# Returns the raw API response body with the HTTP status code appended on a new line.
call_gemini_api() {
    local user_input="$1"
    local final_prompt="User question: ${user_input}"
    local api_url="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_NAME}:generateContent?key=${API_KEY}"
    local json_payload
    # Use printf to safely create the JSON payload, combining the system prompt and user prompt.
    json_payload=$(printf '{"contents":[{"parts":[{"text":"%s %s"}]}]}' "$SYSTEM_PROMPT" "$final_prompt")

    # Start the Zenity progress dialog in the background.
    zenity --progress --title="Please Wait" --text="Querying AI ${MODEL_NAME}..." \
      --pulsate --auto-close --no-cancel --width=300 &
    # Store the Process ID (PID) of the backgrounded Zenity dialog.
    local progress_pid=$!

    # Set a trap: This command will execute automatically when the script exits for ANY reason
    # (normal termination, error, or Ctrl+C). The single quotes delay variable expansion,
    # ensuring the 'kill' command works correctly to close the progress window.
    trap 'kill ${progress_pid} &>/dev/null' EXIT

    local api_response
    # Execute the API call using curl.
    # -s: silent mode.
    # -w: write-out format, here used to append the HTTP status code on a new line.
    # -H: set request header.
    # -d: send data payload.
    api_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
      -H "Content-Type: application/json" \
      -d "${json_payload}" \
      "${api_url}")

    # Explicitly kill the progress dialog immediately after curl finishes.
    # This provides instant feedback to the user. The trap serves as a final backup.
    kill "${progress_pid}" &>/dev/null

    # Disarm the trap now that the critical operation (curl) is complete.
    # This prevents the trap from accidentally closing other Zenity windows later in the script.
    trap - EXIT

    # Output the raw response for the processing function.
    echo "$api_response"
}

# Parses the raw API response, handles errors, and extracts the clean text.
# Arguments:
#   $1: The raw output from call_gemini_api().
# Returns 0 on success (echoing the text) or 1 on failure.
process_api_response() {
    local api_response="$1"
    local http_status
    # Extract the HTTP status code from the last line of the input.
    http_status=$(echo "$api_response" | tail -n1 | cut -d: -f2)
    local api_response_body
    # Extract the JSON body by removing the last line (the status code line).
    api_response_body=$(echo "$api_response" | sed '$d')

    # Check if the API call was successful.
    if [[ "$http_status" -ne 200 ]]; then
        local error_message
        # Attempt to parse a detailed error message from the JSON response.
        # The 'jq' ' // "..." ' syntax provides a fallback default message.
        error_message=$(echo "$api_response_body" | jq -r '.error.message // "Unknown API error."')
        show_error "The API returned an error (Code: $http_status).\n\n<b>Details:</b> $error_message"
        return 1 # Signal failure.
    fi

    local response_text
    # Extract the clean response text from the successful JSON response.
    response_text=$(echo "${api_response_body}" | jq -r '.candidates[0].content.parts[0].text')

    # Check if the response is empty or null (e.g., blocked by safety filters).
    if [[ -z "$response_text" || "$response_text" == "null" ]]; then
        show_error "The API response was empty or blocked by safety policies."
        return 1 # Signal failure.
    fi

    # Output the clean text and signal success.
    echo "$response_text"
    return 0
}

# --- SCRIPT EXECUTION ---
# Call the main function to start the script.
main
