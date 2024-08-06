#!/bin/bash

USER_STORE="user-store.txt"
SCRIPT_DIR=$(dirname "$0")
LIFESPAN_FILE="$SCRIPT_DIR/life-expectancy.csv"

function hash_password {
    echo -n "$1" | openssl dgst -sha256 | awk '{print $2}'
}

function generate_uuid {
    openssl rand -hex 16 | sed 's/\(..\)/\1-/g;s/-$//'
}

function initiate_registration {
    read -p "Enter user email: " email
    uuid=$(generate_uuid)
    role="PATIENT"
    echo "$email,$uuid,$role" >> $USER_STORE
    echo "User initiated. UUID: $uuid"
}

function complete_registration {
    read -p "Enter UUID: " uuid
    if grep -q "$uuid" "$USER_STORE"; then
        read -p "Enter First Name: " firstName
        read -p "Enter Last Name: " lastName
        read -p "Enter Date of Birth (YYYY-MM-DD): " dob
        read -p "Are you HIV positive? (yes/no): " hivPositive
        if [[ $hivPositive == "yes" ]]; then
            read -p "Enter Diagnosis Date (YYYY-MM-DD): " diagnosisDate
            read -p "Are you on ART drugs? (yes/no): " onART
            if [[ $onART == "yes" ]]; then
                read -p "Enter ART Start Date (YYYY-MM-DD): " artStartDate
            else
                artStartDate=""
            fi
        else
            diagnosisDate=""
            artStartDate=""
        fi
        read -p "Enter Country Code: " country
        read -p "Enter Password: " password
        hashedPassword=$(hash_password "$password")
        email=$(grep "$uuid" "$USER_STORE" | awk -F, '{print $1}')
        role=$(grep "$uuid" "$USER_STORE" | awk -F, '{print $3}')

        new_record="$email,$uuid,$firstName,$lastName,$dob,$hivPositive,$diagnosisDate,$onART,$artStartDate,$country,$hashedPassword,$role"
        
    
        # Escape slashes and other special characters in the new record
        new_record_escaped=$(echo "$new_record" | sed -e 's/[\/&]/\\&/g')

        # Update the user record in the file
        sed -i "s/^$email,$uuid,$role$/$new_record_escaped/" $USER_STORE
        
        if grep -q "$new_record" "$USER_STORE"; then
            echo "Registration completed for $email"
        else
            echo "Failed to update the user-store.txt file."
        fi
    else
        echo "UUID not found."
    fi
}

function login {
    read -p "Enter Email: " email
    read -sp "Enter Password: " password
    echo
    hashedPassword=$(hash_password "$password")
    userData=$(grep "$email" "$USER_STORE")
    storedPassword=$(echo $userData | awk -F, '{print $11}')
    if [[ $hashedPassword == $storedPassword ]]; then
        echo "Login successful."
        role=$(echo $userData | awk -F, '{print $12}')
        if [[ $role == "ADMIN" ]]; then
            admin_menu
        else
            patient_menu
        fi
    else
        echo "Invalid credentials."
    fi
}

function admin_menu {
    echo "Admin Menu"
    echo "1. Initiate Registration"
    echo "2. Download empty CSV file"
    echo "3. Logout"
    read -p "Enter choice: " choice
    case $choice in
        1)
            initiate_registration
            ;;
        2)
            echo "Downloading empty CSV files..."
            echo "" > users.csv
            echo "" > analytics.csv
            ;;
        3)
            return
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
}

function patient_menu {
    echo "Patient Menu"
    echo "1. View Profile Data"
    echo "2. Update Profile Data"
    echo "3. Calculate Life Expectancy"
    echo "4. Logout"
    read -p "Enter choice: " choice
    case $choice in
        1)
            echo "##### View Profile Data (UPCOMING Deliverable) #######"
            ;;
        2)
            echo "##### Update Profile Data (UPCOMING Deliverable) ######"
            ;;
        3)
            calculate_life_expectancy
            ;;
        4)
            return
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
}

function calculate_life_expectancy {
    read -p "Enter your Email: " email
    userData=$(grep "$email" "$USER_STORE")
    if [[ -z "$userData" ]]; then
        echo "User not found."
        return
    fi

    birthYear=$(echo $userData | awk -F, '{print $5}' | cut -d'-' -f1)
    hivPositive=$(echo $userData | awk -F, '{print $6}')
    if [[ $hivPositive != "yes" ]]; then
        echo "You are not HIV positive. No need for calculation."
        return
    fi

    diagnosisYear=$(echo $userData | awk -F, '{print $7}' | cut -d'-' -f1)
    onART=$(echo $userData | awk -F, '{print $8}')
    if [[ $onART == "yes" ]]; then
        artStartYear=$(echo $userData | awk -F, '{print $9}' | cut -d'-' -f1)
    else
        artStartYear=$diagnosisYear
    fi
    country=$(echo $userData | awk -F, '{print $10}')
    lifeExpectancy=$(grep "$country" "$LIFESPAN_FILE" | awk -F, '{print $7}')
    currentYear=$(date +%Y)
    age=$(($currentYear - $birthYear))
    remainingYears=$(awk "BEGIN {print $lifeExpectancy - $age}")

    if (( $(awk "BEGIN {print ($remainingYears <= 5)}") )); then
        echo "Lifespan: $(($birthYear + 5))"
        return
    fi

    remainingYearsOnDiagnosis=$(awk "BEGIN {print $lifeExpectancy - $diagnosisYear}")
    reductionRate=0.90
    for (( i=$diagnosisYear+1; i<=$artStartYear; i++ )); do
        remainingYearsOnDiagnosis=$(awk "BEGIN {print $remainingYearsOnDiagnosis * $reductionRate}")
    done

    finalRemainingYears=$(awk "BEGIN {print $remainingYearsOnDiagnosis * 0.90}")
    lifespan=$(($diagnosisYear + ${finalRemainingYears%.*}))

    echo "Lifespan: $lifespan"
}

case $1 in
    initiate)
        initiate_registration
        ;;
    complete)
        complete_registration
        ;;
    login)
        login
        ;;
    *)
        echo "Usage: $0 {initiate|complete|login}"
        ;;
esac
