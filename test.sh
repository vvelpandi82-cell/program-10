#!/bin/bash

DB="CollegeDB"
TOTAL=0
FAILED=0

MYSQL="mysql -h 127.0.0.1 -P 3306 -uroot -p${MYSQL_ROOT_PASSWORD}"

echo "=========================================="
echo "RDBMS PROGRAM 10 - AUTOGRADING"
echo "LEFT JOIN AND RIGHT JOIN"
echo "=========================================="

echo "Checking MySQL connection..."

if $MYSQL -e "SELECT 1;" >/dev/null 2>&1; then
    echo "MySQL connection successful."
else
    echo "ERROR: Cannot connect to MySQL."
    exit 1
fi

echo
echo "Creating fresh CollegeDB database..."

$MYSQL -e "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB;"

echo "Executing student_solution.sql..."

if $MYSQL < student_solution.sql >/dev/null 2>&1; then
    echo "SQL execution completed."
else
    echo "ERROR: SQL execution failed."
    exit 1
fi

run_test() {
    local num="$1"
    local description="$2"
    local query="$3"
    local expected="$4"

    result=$($MYSQL -N -B "$DB" -e "$query" 2>/dev/null | tr -d '\r')

    if [ "$result" = "$expected" ]; then
        echo "Test Case $num PASS: $description"
        TOTAL=$((TOTAL + 1))
    else
        echo "Test Case $num FAIL: $description"
        echo "Expected: $expected"
        echo "Got: $result"
        FAILED=$((FAILED + 1))
    fi
}

run_test 1 "Course table exists" \
"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB' AND table_name='Course';" \
"1"

run_test 2 "Enrollment table exists" \
"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB' AND table_name='Enrollment';" \
"1"

run_test 3 "Course table has 3 records" \
"SELECT COUNT(*) FROM Course;" \
"3"

run_test 4 "Enrollment table has 4 records" \
"SELECT COUNT(*) FROM Enrollment;" \
"4"

run_test 5 "Course values are correct" \
"SELECT COUNT(*) FROM Course WHERE (CourseID=201 AND CourseName='Database Systems' AND Credits=4) OR (CourseID=202 AND CourseName='Data Structures' AND Credits=3) OR (CourseID=203 AND CourseName='Mathematics' AND Credits=4);" \
"3"

run_test 6 "Enrollment values are correct" \
"SELECT COUNT(*) FROM Enrollment WHERE (EnrollmentID=1 AND StudentID=1001 AND CourseID=201) OR (EnrollmentID=2 AND StudentID=1001 AND CourseID=202) OR (EnrollmentID=3 AND StudentID=1002 AND CourseID=203) OR (EnrollmentID=4 AND StudentID=1003 AND CourseID=201);" \
"4"

run_test 7 "LEFT JOIN returns 4 records" \
"SELECT COUNT(*) FROM Course LEFT JOIN Enrollment ON Course.CourseID=Enrollment.CourseID;" \
"4"

run_test 8 "RIGHT JOIN returns 4 records" \
"SELECT COUNT(*) FROM Course RIGHT JOIN Enrollment ON Course.CourseID=Enrollment.CourseID;" \
"4"

run_test 9 "LEFT JOIN Database Systems mapping" \
"SELECT COUNT(*) FROM Course LEFT JOIN Enrollment ON Course.CourseID=Enrollment.CourseID WHERE Course.CourseID=201 AND Course.CourseName='Database Systems';" \
"2"

run_test 10 "RIGHT JOIN complete mapping" \
"SELECT COUNT(*) FROM Course RIGHT JOIN Enrollment ON Course.CourseID=Enrollment.CourseID WHERE Course.CourseID IS NOT NULL;" \
"4"

echo
echo "=========================================="
echo "Total Marks: $TOTAL / 10"
echo "=========================================="

if [ "$FAILED" -eq 0 ]; then
    echo "All test cases passed."
    exit 0
else
    echo "$FAILED test case(s) failed."
    exit 1
fi
