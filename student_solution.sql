USE CollegeDB;

CREATE TABLE Course(
    CourseID INT,
    CourseName VARCHAR(30),
    Credits INT
);

INSERT INTO Course VALUES
(201, 'Database Systems', 4),
(202, 'Data Structures', 3),
(203, 'Mathematics', 4);

CREATE TABLE Enrollment(
    EnrollmentID INT,
    StudentID INT,
    CourseID INT
);

INSERT INTO Enrollment VALUES
(1, 1001, 201),
(2, 1001, 202),
(3, 1002, 203),
(4, 1003, 201);

SELECT Course.CourseID,
       Course.CourseName,
       Enrollment.StudentID
FROM Course
LEFT JOIN Enrollment
ON Course.CourseID = Enrollment.CourseID;

SELECT Course.CourseID,
       Course.CourseName,
       Enrollment.StudentID
FROM Course
RIGHT JOIN Enrollment
ON Course.CourseID = Enrollment.CourseID;
