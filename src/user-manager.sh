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
                data=$(echo "$userData" | awk -F, '{print "Email Address:","",$1 "\n","First Name:", "", $3,"Last Name:","",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "HIV Diagnosis Date:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","ART Start Date:" ,"", $9 "\n","Country:","",$10 "\n"}')
                echo "$data"
            else
                echo "User not found!"
            fi
            ;;
        2)
            echo "Update Profile Data"
            echo "Edit Information"
            echo "1. EmailAddress"
            echo "2. FirstName"
            echo "3. LastName"
            echo "4. Enter Date of Birth (YYYY-MM-DD)"
            echo "5. Are you HIV positive? (yes/no)"
            echo "6. Enter Diagnosis Date (YYYY-MM-DD)"
            echo "7. Are you on ART drugs? (yes/no)"
            echo "8.Enter ART Start Date (YYYY-MM-DD)"
            echo "9. Country"
            echo "10. Change Password"
            read -p "Enter choice:" choice
            case $choice in
                1)
                read -p "Enter Old Email address" OldEmailAddress
                read -p "Enter New EmailAddress: " NewEmailAddress 
                sed -i "s/$OldEmailAddress/$NewEmailAddress/g" user-store.txt
                echo "Email address updated!" 
                grep "$NewEmailAddress" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                2)
                read -p "Enter Old FirstName: " OldFirstName
                read -p "Enter New FirstName: " NewFirstName 
                sed -i "s/$OldFirstName/$NewFirstName/g" user-store.txt
                echo ""
                echo "First Name updated!" 
                echo ""
                grep "$NewFirstName" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                3)
                read -p "Enter Old LastName: " OldLastName
                read -p "Enter New LastName: " NewLastName 
                sed -i "s/$OldLastName/$NewLastName/g" user-store.txt
                echo "Last Name updated!" 
                grep "$NewLastName" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                4)
                read -p "Enter Old Date of Birth: " OldDOB
                read -p "Enter New Date of Birth: " NewDOB 
                sed -i "s/$OldDOB/$NewDOB/g" user-store.txt
                echo "Date of Birth updated!" 
                grep "$NewDOB" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                5)
                read -p "Enter Old HIV Status: " OldHIVStatus
                read -p "Enter New HIV Status: " NewHIVStatus 
                sed -i "s/$OldHIVStatus/$NewHIVStatus/g" user-store.txt
                echo "HIV Status updated!" 
                grep "$OldHIVStatus" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                6)
                read -p "Enter Old Diagnosis Date: " OldDiagnosisDate
                read -p "Enter New Diagnosis Date: " NewDiagnosisDate
                sed -i "s/$OldDiagnosisDate/$NewDiagnosisDate/g" user-store.txt
                echo "Diagnosis date updated!" 
                grep "$NewDiagnosisDate" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "/n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                7)
                read -p "Enter Old ART Status: " OldARTStatus
                read -p "Enter New ART Status: " NewARTStatus
                sed -i "s/$OldARTStatus/$NewARTStatus/g" user-store.txt
                echo "ART status updated!" 
                grep "$NewARTStatus" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                8)
                read -p "Enter Old ART Start Date: " OldARTStartDate
                read -p "Enter New ART Start Date: " NewARTStartDate 
                sed -i "s/$OldARTStartDate/$NewARTStartDate/g" user-store.txt
                echo "ART start date updated!" 
                grep "$NewARTStartDate" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                9)
                read -p "Enter Old Country: " OldCountry
                read -p "Enter New Country: " NewCountry
                sed -i "s/$OldCountry/$NewCountry/g" user-store.txt
                echo "Country updated!" 
                grep "$NewCountry" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
                10)
                read -p "Enter Old Password: " OldPassword
                read -p "Enter New Password: " NewPassword
                hashedPassword=$(hash_password "$OldPassword")
                sed -i "s/$OldPassword/$hashedPassword/g" user-store.txt
                echo "Password changed!" 
                grep "$NewPassword" user-store.txt | awk -F, '{print "EmailAddress:","",$1 "\n","FirstName:", "", $3 "\n","LastName:","\n",$4 "\n","DOB:" ,"", $5 "\n","HIV status:","", $6 "\n", "DiagnosisDate:" ,"", $7 "\n","ART Status:" ,"", $8 "\n","StartDate:" ,"", $9 "\n","Country:","",$10 "\n"}'
                ;;
            *)
                echo "Invalid choice"
                ;;
            esac
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
