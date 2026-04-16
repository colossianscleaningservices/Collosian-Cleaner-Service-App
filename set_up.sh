#!/bin/bash

# Define colors
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to run a command and track its success or failure
run_command() {
    echo -e "${CYAN}====== Running: $1 ======${RESET}"
    eval $1
    if [ $? -eq 0 ]; then
        RESULTS+=("${GREEN}$1: SUCCESS${RESET}")
    else
        RESULTS+=("${RED}$1: FAILED${RESET}")
    fi
}

# Function to display header
display_header() {
    echo -e "\n${YELLOW}================================${RESET}"
    echo -e "${YELLOW}        CCS-App SETUP SCRIPT        ${RESET}"
    echo -e "${YELLOW}================================${RESET}\n"
}

# Array to store results
RESULTS=()

# Display header
display_header

echo -e "${CYAN}Starting WAVTech app configuration...${RESET}\n"

# Run commands for WAVTech setup
run_command "dart run change_app_package_name:main 'app.ccs.io'"
run_command "dart run rename_app:main all='Colossians'"
run_command "dart run flutter_native_splash:create"
run_command "dart run flutter_launcher_icons"
# run_command "flutterfire configure -p collosian-cleaner-service-app"

# Additional setup commands for WAVTech
echo -e "\n${CYAN}====== Additional Setup Commands ======${RESET}"
run_command "flutter clean"
run_command "flutter pub get"

# Generate assets if flutter_gen is configured
if grep -q "flutter_gen_runner:" pubspec.yaml; then
    run_command "fluttergen"
fi

# Display summary results
echo -e "\n${CYAN}====== Setup Summary ======${RESET}"
for result in "${RESULTS[@]}"; do
    echo -e "$result"
done

echo -e "\n${GREEN}CCS-App setup completed!${RESET}"
echo -e "${YELLOW}Next steps:${RESET}"
echo -e "1. Configure Firebase (if needed): flutterfire configure"
echo -e "2. Review .env / secrets before running"
echo -e "3. Update API + OneSignal keys in services"
echo -e "4. Test the app: flutter run"

# Hold for 5 seconds
sleep 5 