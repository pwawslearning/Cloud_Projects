<?php
// Database connection details
$servername2 = "read-replica.cfkuekeg8zet.ap-southeast-1.rds.amazonaws.com";
$username2 = "admin";
$password2 = "admin123";
$dbname2 = "mydb";

// Create connection
$conn2 = new mysqli($servername2, $username2, $password2, $dbname2);

// Check connection
if ($conn2->connect_error) {
    die("Connection failed: " . $conn2->connect_error);
}

// Fetch all records from the users table
$sql = "SELECT id, name, email FROM users";
$result = $conn2->query($sql);

if ($result->num_rows > 0) {
    echo "<h1>Submitted Data</h1>";
    echo "<table border='1'><tr><th>ID</th><th>Name</th><th>Email</th></tr>";
    while($row = $result->fetch_assoc()) {
        echo "<tr><td>" . $row["id"]. "</td><td>" . $row["name"]. "</td><td>" . $row["email"]. "</td></tr>";
    }
    echo "</table>";
} else {
    echo "0 results";
}

// Close connection
$conn2->close();
?>