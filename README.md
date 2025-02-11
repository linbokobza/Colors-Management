# 🎨 Color Inventory Management System  

## 📌 Project Overview  
This is a web-based application for managing a color inventory. It allows users to perform CRUD operations on a color database and modify the display order dynamically.  

## ✨ Features  
✅ View Colors  
➕ Add New Color  
🗑 Delete Color  
✏ Edit Color  
🔄 Modify Color Order (Bonus Feature)  

## 🛠 Technology Stack  
- 🖥 **Backend:** ASP.NET (VB.NET)  
- 📊 **Database:** SQL Server  
- 🌐 **Frontend:** jQuery + AJAX for seamless data updates  

## 🚀 Setup Instructions  

### 1️⃣ Clone the Repository  
```bash
git clone https://github.com/your-username/color-inventory.git
cd color-inventory
```

### 2️⃣ Configure the Database Connection
Edit your web.config file under <connectionStrings>:
```bash
<connectionStrings>
    <add name="ColorsDB" connectionString="YOUR_DATABASE_CONNECTION_STRING" providerName="System.Data.SqlClient" />
</connectionStrings>
```

### 3️⃣ Create the Database Table
Run the following SQL query to create the ColorsStock table:

```bash
CREATE TABLE ColorsStock (
    ColorID NVARCHAR(50) PRIMARY KEY,
    ColorName NVARCHAR(50),
    Price INT,
    DisplayOrder INT,
    Available BIT
);
```

### 4️⃣ Build & Run the Project
- Open the project in Visual Studio
- Build and run the application on your local server

### 5️⃣ Access the Application
- Open your browser and navigate to:
```bash
http://localhost:your-port
```
- Start managing your color inventory effortlessly! 🎨


⭐ If you find this project helpful, consider giving it a star ⭐ on GitHub!
