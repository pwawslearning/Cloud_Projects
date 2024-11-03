<?php
// Database connection details
$db1_servername = "mydb-instance.cfkuekeg8zet.ap-southeast-1.rds.amazonaws.com";
$db1_username = "admin";
$db1_password = "admin123";
$db1_name = "mydb";

// Create connection
$conn1 = new mysqli($db1_servername, $db1_username, $db1_password, $db1_name);

// Check connection
if ($conn1->connect_error) {
    die("Connection failed: " . $conn1->connect_error);
}

// Get form data
$name = $_POST['name'];
$email = $_POST['email'];

// Insert data into the database
$sql = "INSERT INTO users (name, email) VALUES ('$name', '$email')";
if ($conn1->query($sql) === TRUE) {
    echo "New record created successfully. <a href='index.php'>Go back</a>";
} else {
    echo "Error: " . $sql . "<br>" . $conn1->error;
}

// Close connection
$conn1->close();
?>