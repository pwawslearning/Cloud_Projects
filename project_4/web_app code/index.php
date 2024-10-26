<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tier 2 Web Application</title>
</head>
<body>
    <h1>Welcome to the Tier 2 Web Application</h1>
    <form action="insert.php" method="POST">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required><br><br>
        
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required><br><br>
        
        <button type="submit">Submit</button>
    </form>
    <br>
    <a href="fetch.php">View Submitted Data</a>
</body>
</html>
