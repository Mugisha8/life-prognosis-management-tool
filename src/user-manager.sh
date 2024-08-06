#!/bin/bash

USER_STORE="user-store.txt"

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
        read -p "Enter Country (ISO Code): " country
        read -p "Enter Password: " password
        hashedPassword=$(hash_password "$password")
        email=$(grep "$uuid" "$USER_STORE" | awk -F, '{print $1}')
        role=$(grep "$uuid" "$USER_STORE" | awk -F, '{print $3}')
        sed -i "s/$email,$uuid,$role$/$email,$uuid,$firstName,$lastName,$dob,$hivPositive,$diagnosisDate,$onART,$artStartDate,$country,$hashedPassword,$role/" $USER_STORE
        echo "Registration completed for $email"
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
            echo "View Profile Data"
            if [[ -n $userData ]]; then 
                data=$(echo "$userData" | awk -F, '{print "EmailAdress:","",$1 "\n","Name:", "", $3,$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}')
                echo "$data"
            else
                echo "User not found!"
            fi
            ;;
        2)
            echo "##### Update Profile Data (UPCOMING Deliverable) ######"
            ;;
        3)
            echo "##### Calculate Life Expectancy (UPCOMING Deliverable) ######"
            ;;
           
        *)
            echo "Invalid choice."
            ;;
    esac
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
