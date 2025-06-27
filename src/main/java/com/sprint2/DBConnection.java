package com.sprint2;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final Logger logger = LoggerFactory.getLogger(DBConnection.class);

    private static final String URL = "jdbc:oracle:thin:@localhost:1521/XEPDB1"; // Service name format
    private static final String USER = "SYSTEM";
    private static final String PASSWORD = "Hussain7684";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            logger.info("Oracle JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            logger.error("Oracle JDBC Driver not found.", e);
            throw new SQLException("Oracle JDBC Driver not found.", e);
        }

        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            logger.info("Database connection established for user '{}'", USER);
            return conn;
        } catch (SQLException e) {
            logger.error("Failed to connect to DB with user '{}': {}", USER, e.getMessage());
            throw e;
        }
    }
}
