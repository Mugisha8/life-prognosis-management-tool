#!/bin/bash

USER_STORE="user-store.txt"

function hash_password {
    echo -n "$1" | openssl dgst -sha256 | awk '{print $2}'
}

function initiate_registration {
    read -p "Enter user email: " email
    uuid=$(uuidgen)
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
        sed -i "s/$uuid,.*$/$email,$uuid,$role,$firstName,$lastName,$dob,$hivPositive,$diagnosisDate,$onART,$artStartDate,$country,$hashedPassword/" $USER_STORE
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
    storedPassword=$(echo $userData | awk -F, '{print $13}')
    if [[ $hashedPassword == $storedPassword ]]; then
        echo "Login successful."
        role=$(echo $userData | awk -F, '{print $3}')
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
    echo "1. Download empty CSV file"
    echo "2. Logout"
    read -p "Enter choice: " choice
    case $choice in
        1)
            echo "Downloading empty CSV files..."
            echo "" > users.csv
            echo "" > analytics.csv
            ;;
        2)
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
    echo "3. Logout"
    read -p "Enter choice: " choice
    case $choice in
        1)
            echo "View Profile Data (not implemented)"
            ;;
        2)
            echo "Update Profile Data (not implemented)"
            ;;
        3)
            return
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
