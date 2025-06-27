package com.sprint2;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // This URL correctly points to the pluggable database XEPDB1
    private static final String URL = "jdbc:oracle:thin:@localhost:1521/XEPDB1";
    
    // Use the SYSTEM user for this practice project
    private static final String USER = "SYSTEM";
    
    // !!! IMPORTANT: Replace this with your actual Oracle password !!!
    private static final String PASSWORD = "Hussain7684"; 

    public static Connection getConnection() throws SQLException {
        // This is a modern way to ensure the driver is loaded
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
