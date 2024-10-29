<?php
// Database connection details
$servername = "db-instance.xxxxxxxxxx.ap-southeast-1.rds.amazonaws.com";
$username = "admin";
$password = "admin123";
$dbname = "mydb";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get form data
$name = $_POST['name'];
$email = $_POST['email'];

// Insert data into the database
$sql = "INSERT INTO users (name, email) VALUES ('$name', '$email')";
if ($conn->query($sql) === TRUE) {
    echo "New record created successfully. <a href='index.php'>Go back</a>";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

// Close connection
$conn->close();
?>
