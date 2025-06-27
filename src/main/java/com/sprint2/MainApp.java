package com.sprint2;

import com.sprint2.dao.ComplaintDAO;
import com.sprint2.model.Complaint;
import java.sql.Connection;
import java.sql.SQLException;

public class MainApp {
    public static void main(String[] args) {
        System.out.println("--- Starting Grievance System JDBC Test ---");

        // 1. Test Database Connection
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("SUCCESS: Connected to Oracle Database successfully!");
            }
        } catch (SQLException e) {
            System.err.println("FATAL ERROR: Could not connect to the database. Check credentials in DBConnection.java.");
            System.err.println(e.getMessage());
            return; // Exit if we can't connect
        }

        ComplaintDAO dao = new ComplaintDAO();

        // 2. Simulate creating a new complaint
        System.out.println("\n--- TEST: Creating a new complaint... ---");
        Complaint c1 = new Complaint("Oracle DB connection timeout during ticket submission", "Open");
        dao.submitComplaint(c1);

        // 3. Simulate updating the status. Let's assume the new complaint got ID=1
        System.out.println("\n--- TEST: Updating complaint status... ---");
        dao.updateResponse(1, "Assigned to DB Admin");

        // 4. Simulate escalating the complaint
        System.out.println("\n--- TEST: Escalating complaint... ---");
        dao.escalateComplaint(1);

        System.out.println("\n--- JDBC Test Completed ---");
    }
}
