package com.sprint2;
import com.sprint2.dao.ComplaintDAO;
import com.sprint2.model.Complaint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;

public class MainApp {

    private static final Logger logger = LoggerFactory.getLogger(MainApp.class);

    public static void main(String[] args) {

        // Simulated login attempt
        String username = "admin";
        String password = "password123"; // In real app, never log raw passwords

        if (authenticate(username, password)) {
            logger.info("Login successful for user: {}", username);
        } else {
            logger.warn("Login failed for user: {}", username);
        }

        // DB connection
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                logger.info("Connected to Oracle Database successfully!");
            } else {
                logger.error("Connection to Oracle Database failed.");
            }
        } catch (SQLException e) {
            logger.error("Error connecting to DB: {}", e.getMessage());
        }

        // Complaint operations
        ComplaintDAO dao = new ComplaintDAO();

        Complaint c1 = new Complaint("Oracle DB connection timeout during ticket submission", "Open");
        dao.submitComplaint(c1);
        logger.info("Submitted complaint: {}", c1.getDescription());

        dao.updateResponse(1, "Assigned to DB Admin");
        logger.info("Updated response for Complaint ID 1: Assigned to DB Admin");

        dao.escalateComplaint(1);
        logger.warn("Complaint ID 1 has been escalated.");
    }

    private static boolean authenticate(String username, String password) {
        return "admin".equals(username) && "password123".equals(password);
    }
}
