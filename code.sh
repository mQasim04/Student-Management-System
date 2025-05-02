#!/bin/bash
	#============================================================================#
	#-------------------Student Management System (SMS)--------------------------#
	#============================================================================#
	#                                                                            #
	# This is a bash script that is command-line-based system                    #
	# that is designed to manage about 20 students by a teacher.                 #
	# this system allows teacher to register more students, update marks,        #
	# generate reports, assign grades, remove students, pass or fail students    #
	# with specific grades. Here, Students can also login with their credentials #
	# to view grades, reports like pass or fail.                                 #
	#                                                                            #
	#============================================================================#


student_data_file="students.txt"
USER_FILE="users.txt"
TEACHER_USERNAME="teacher"
TEACHER_PASSWORD="admin123"
MAX_STUDENTS=20
passing_gpa=2.0

#checking if files exists...if not then create them using touch
[ -f "$student_data_file" ] || touch "$student_data_file"
[ -f "$USER_FILE" ] || touch "$USER_FILE"

#Pause the execution untill user enter something, clear screen when user input something
pause() {
    echo "press any key to continue..."
    read -n 1 -s
    clear
}

#this function register new students with username and password
register_student() {
    if [ $(wc -l < "$USER_FILE") -ge $MAX_STUDENTS ]; then
        echo "BCS4B can have only 20 students can't add more(moyen moyen)"
        pause
        return
    fi
    echo -n "enter username: "
    read username
    
    if grep -q "^$username " "$USER_FILE"; then  #if user exist already
        echo "already exist with this name use unique name..."
        pause
        return
    fi
    #enter the password for user
    echo -n "Enter password: "
    read  password
    echo
    echo "$username $password" >> "$USER_FILE"

    echo "student registered Alhamdulillah...!!!!"
    pause
}

#this function add more students using their details like roll no. including their marks 
add_student() {
    echo -n "Enter registered username: "
    read username

    if ! grep -q "^$username " "$USER_FILE"; then
        echo "Student should be registered to be added to BCS4B"
        pause
        return
    fi
    #read marks from user (Teacher)
    echo -n "Enter Roll No: "
    read roll_no
    echo -n "Enter OS Marks: "
    read os_marks
    echo -n "Enter DB Marks: "
    read db_marks
    echo -n "Enter ALGO Marks: "
    read algo_marks
    echo -n "Enter FOM Marks: "
    read fom_marks
    echo -n "Enter PROB Marks: "
    read prob_marks
    echo -n "Enter SDA Marks: "
    read sda_marks
    #claculate the total marks
    total_marks=$((os_marks + db_marks + algo_marks + fom_marks + prob_marks + sda_marks))

    echo "$username $roll_no $username $os_marks $db_marks $algo_marks $fom_marks $prob_marks $sda_marks $total_marks" >> "$student_data_file"

    echo "Student details added successfully....!!!"
    pause
}

#this function will update the marks of students by entering the id of students
update_numbers() {
    echo -n "Enter Roll Number: "
    read roll_no

    # Check if the roll number exists in the file
    if ! grep -q " $roll_no " "$student_data_file"; then
        echo "No student found with this Roll Number."
        pause
        return
    fi

    # Remove the old record from the file
    grep -v " $roll_no " "$student_data_file" > temp.txt

    # Prompt for marks in each subject
    subjects=("OS" "DB" "ALGO" "FOM" "PROB" "SDA")
    marks=()
    total_marks=0  # Initialize total marks

    for subject in "${subjects[@]}"; do
        while true; do
            echo -n "Enter marks for $subject (0-100): "
            read mark
            if [[ "$mark" =~ ^[0-9]+$ ]] && [ "$mark" -ge 0 ] && [ "$mark" -le 100 ]; then
                marks+=("$mark")
                total_marks=$((total_marks + mark))  # Add mark to total
                break
            else
                echo "Invalid input! Enter a number between 0 and 100."
            fi
        done
    done

    student_record=$(grep " $roll_no " "$student_data_file" | awk '{print $1, $2, $3}')

    echo "$student_record ${marks[*]} $total_marks" >> temp.txt

    # Save the updated records
    mv temp.txt "$student_data_file"

    echo "Marks updated successfully for Roll No: $roll_no."
    pause
}


#this function print the details of each student in table form by reading details from the file
view_students() {
    clear
    if [ ! -s "$student_data_file" ]; then
        echo "No student records found."
    else
        echo -e "Roll No     Name            OS   DB  ALGO  FOM  PROB  SDA  Total"
        echo "------------------------------------------------------------------"
        while IFS=' ' read -r username roll_no name os db algo fom prob sda total; do
            printf "%-10s %-15s %-4s %-4s %-5s %-4s %-5s %-4s %-5s\n" \
                "$roll_no" "$name" "$os" "$db" "$algo" "$fom" "$prob" "$sda" "$total"
        done < "$student_data_file"
    fi
    pause
}

#this function will generate the reports by asking user for ascending or decending order
generate_report() {
    echo "Choose sorting order:"
    echo "1. Ascending"
    echo "2. Descending"
    echo -n "Choose an option: "
    read choice

    case $choice in
        1) sort -k10 -n "$student_data_file" ;;	#sort on basis of 10th column of file
        2) sort -k10 -nr "$student_data_file" ;;
        *) echo "Invalid option." ;;
    esac
    pause
}

#This function will calculate the grades based on the marks for each student stored in file 
calculate_grades() {
    clear
    echo -e "Username    RollNo    Total Marks    Grade    GPA"
    echo "-----------------------------------------------------"
    
    while read -r username roll_no name os db algo fom prob sda; do
        # Check if all marks are numeric
        if ! [[ "$os" =~ ^[0-9]+$ && "$db" =~ ^[0-9]+$ && "$algo" =~ ^[0-9]+$ && "$fom" =~ ^[0-9]+$ && "$prob" =~ ^[0-9]+$ && "$sda" =~ ^[0-9]+$ ]]; then
            echo -e "$username    $roll_no    ERROR    -    -"
            continue
        fi

        # Calculate total marks
        total_marks=$((os + db + algo + fom + prob + sda))
        max_marks=600  # Assuming each subject is out of 100

        # Calculate percentage
        percentage=$((total_marks * 100 / max_marks))

        # Assign Grade & GPA
        if [ "$percentage" -ge 90 ]; then grade="A+"; gpa=4;
        elif [ "$percentage" -ge 85 ]; then grade="A"; gpa=4;
        elif [ "$percentage" -ge 80 ]; then grade="A-"; gpa=3.6;
        elif [ "$percentage" -ge 75 ]; then grade="B+"; gpa=3.33;
        elif [ "$percentage" -ge 70 ]; then grade="B"; gpa=3;
        elif [ "$percentage" -ge 65 ]; then grade="B-"; gpa=2.67;
        elif [ "$percentage" -ge 60 ]; then grade="C+"; gpa=2.33;
        elif [ "$percentage" -ge 55 ]; then grade="C"; gpa=2;
        elif [ "$percentage" -ge 50 ]; then grade="C-"; gpa=1.67;
        elif [ "$percentage" -ge 45 ]; then grade="D+"; gpa=1.33;
        elif [ "$percentage" -ge 40 ]; then grade="D"; gpa=1;
        else grade="F"; gpa=0; fi

        # Print results
        printf "%-12s %-8s %-12s %-8s %.2f\n" "$username" "$roll_no" "$total_marks" "$grade" "$gpa"
    
    done < "$student_data_file"
    
    pause
}

#Student menu allow student to perform their functions like view details or logout
student_menu() {
    local username="$1"

    while true; do
        clear
        echo "1. View My Details"
        echo "2. Logout"
        echo -n "Choose an option: "
        read option

        case $option in
            1)
                # Fix to allow student to view their details based on username
                student_record=$(grep "^$username " "$student_data_file")
                if [ -n "$student_record" ]; then
                    # Show details for the student
                    echo "$student_record" | awk '{print "Roll No:", $2, "\nName:", $3, "\nMarks:", $4}'
                else
                    echo "No records found. Ask the teacher to add your details."
                fi
                read -p "Press Enter to continue..."
                ;;
            2)
                echo "Logging out..."
                break
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    done
}

#Function to print passing status by comparing the entered students' cgpa
list_passed_students() {
    clear
    echo -e "Username    RollNo    Name    Total Marks    Avg %    CGPA"
    echo "------------------------------------------------------------"

    while read -r username roll_no name os db algo fom prob sda total_marks; do
        # Ensure marks are numeric
        if [[ "$total_marks" =~ ^[0-9]+$ ]]; then
            # Calculate average percentage
            avg_percentage=$(echo "scale=2; $total_marks / 6" | bc)

            # Convert percentage to CGPA (assuming 100% = 4.0 CGPA)
            cgpa=$(echo "scale=2; ($avg_percentage / 100) * 4" | bc)

            # Check if the student has passed
            if (( $(echo "$cgpa >= $passing_gpa" | bc -l) )); then
                # Print results
                printf "%-12s %-8s %-8s %-12s %-6.2f %-4.2f\n" "$username" "$roll_no" "$name" "$total_marks" "$avg_percentage" "$cgpa"
            fi
        fi
    done < "$student_data_file"

    pause
}

#this function print fail status based on cgpa of student if less than a criteria
list_failed_students() {
    clear
    echo -e "Username    RollNo    Name    Total Marks    CGPA"
    echo "-----------------------------------------------"
    
    while read -r username roll_no name os db algo fom prob sda total_marks; do
        if [[ "$total_marks" =~ ^[0-9]+$ ]]; then
            # Convert marks to CGPA
            cgpa=$(echo "scale=2; ($total_marks / 600) * 4" | bc)

            # Check if student failed
            if (( $(echo "$cgpa < $passing_gpa" | bc -l) )); then
                printf "%-12s %-8s %-8s %-8s %.2f\n" "$username" "$roll_no" "$name" "$total_marks" "$cgpa"
            fi
        fi
    done < "$student_data_file"

    pause
}

#This function open will allow the teacher to perfporm his/her all functions 
teacher_menu() {
    while true; do
        echo "====================================="
    echo "      Hello Teacher    "
    echo "====================================="
    echo "1. Add Student Details"
    echo "2. View Students"
    echo "3. Update Marks"
    echo "4. Generate Report"
    echo "5. Calculate Grades"
    echo "6. List Passed Students"
    echo "7. List Failed Students"
    echo "8. Logout"
    echo "====================================="
        echo -n "Choose an option: "
        read option

        case $option in
            1) add_student ;;
            2) view_students ;;
            3) update_numbers ;;
            4) generate_report ;;
            5) calculate_grades ;;
            6) list_passed_students ;;
            7) list_failed_students ;;
            8) break ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}

#this funtion help to login wether it is teacher or student to perform their function
login_user() {
    echo -n "Enter username: "
    read username
    echo -n "Enter password: "
    read password

    if [ "$username" = "$TEACHER_USERNAME" ] && [ "$password" = "$TEACHER_PASSWORD" ]; then
        echo "Login successful as Teacher."
        pause
        teacher_menu
        return
    fi

    if grep -q "^$username " "$USER_FILE"; then
        stored_password=$(grep "^$username " "$USER_FILE" | awk '{print $2}')
        if [ "$password" = "$stored_password" ]; then
            echo "Login successful!"
            pause
            student_menu "$username"
        else
            echo "Incorrect password."
        fi
    else
        echo "User not found."
    fi
    pause
}

while true; do
    clear
    echo "====================================="
    echo "      Student Management System     "
    echo "====================================="
    echo "1. Register Student"
    echo "2. Login"
    echo "3. Get Info About Creators"
    echo "4. Exit"
    echo "====================================="
    echo -n "Choose an option: "
    read choice

    case $choice in
        1)
            clear
            register_student
            ;;
        2)
            clear
            login_user
            ;;
        3)
            clear
            echo "====================================="
            echo "        Info About the Creators     "
            echo "====================================="
            echo "1. Bilal Mohsin, Roll Number: F23-0646"
            echo "   Doing CS from FAST NUCES"
            echo ""
            echo "2. M Qasim, Roll Number: F23-0685"
            echo "   Doing CS from FAST NUCES"
            echo ""
            echo "For further information or assistance, feel free to contact us at:"
            echo "FAST NUCES Main Campus, Computer Science Department"
            echo "Email: f230646@cfd.nu.edu.pk"
            echo "Email: f230685@cfd.nu.edu.pk"
            echo "====================================="
            ;;
        4)
            echo "Exiting... Goodbye!"
            break
            ;;
        *)
            echo "Invalid option. Please choose a valid option."
            ;;
    esac
    echo -n "Press Enter to continue..."
    read
done
